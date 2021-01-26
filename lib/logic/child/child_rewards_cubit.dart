import 'package:flutter/widgets.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/gamification/child_reward.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChildRewardsCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();

	List<UIReward> _rewards;

  ChildRewardsCubit(this._activeUser, ModalRoute pageRoute) : super(pageRoute);

	List<UIReward> _updateRewardLimits(List<UIReward> rewards, List<UIChildReward> claimedRewards) {
		Map<ObjectId, int> claimedCount = Map<ObjectId, int>();
		claimedRewards.forEach((element) => claimedCount[element.id] = !claimedCount.containsKey(element.id) ? 1 : claimedCount[element.id] + 1);
		return rewards.where((reward) => reward.limit != null ? reward.limit > (claimedCount[reward.id] ?? 0) : true).toList();
	}

  void doLoadData() async {
	  UIChild child = _activeUser();
		ObjectId caregiverID = child.connections.first;

		if(caregiverID != null && _rewards == null)
			_rewards = (await _dataRepository.getRewards(caregiverId: caregiverID)).map((reward) => UIReward.fromDBModel(reward)).toList();

	  emit(ChildRewardsLoadSuccess(
			_updateRewardLimits(_rewards, child.rewards),
			List.from(child.rewards),
			List.from(child.points)
		));
  }

	void claimReward(UIReward reward) async {
		if (state is! DataLoadSuccess)
			return;
		emit(DataSubmissionInProgress());

    UIChild child = _activeUser();
		List<UIPoints> points = child.points;
		List<UIChildReward> rewards = child.rewards;
		ChildReward model = ChildReward(
			id: reward.id,
			name: reward.name, 
			cost: Points.fromUIPoints(reward.cost),
			icon: reward.icon,
			date: TimeDate.now()
		);
		UIPoints pointCurrency = points.firstWhere((element) => element.type == reward.cost.type, orElse: () => null);
		
		if(pointCurrency != null && pointCurrency.quantity >= reward.cost.quantity) {
			points[points.indexOf(pointCurrency)] = pointCurrency.copyWith(quantity: pointCurrency.quantity - reward.cost.quantity);
			rewards..add(UIChildReward.fromDBModel(model));
			await _dataRepository.claimChildReward(child.id, reward: model, points: points.map((e) =>
				Points.fromUICurrency(UICurrency(type: e.type, title: e.title), e.quantity, creator: e.createdBy)).toList()
			);
			_analyticsService.logRewardBought(reward);
			await _notificationService.sendRewardBoughtNotification(model.id, model.name, child.connections.first, child);
			emit(DataSubmissionSuccess());
		}
	}

	@override
	List<NotificationType> dataTypeSubscription() => [NotificationType.taskApproved];
}

class ChildRewardsLoadSuccess extends DataLoadSuccess {
	final List<UIReward> rewards;
	final List<UIChildReward> claimedRewards;
	final List<UIPoints> points;

	ChildRewardsLoadSuccess(this.rewards, this.claimedRewards, this.points);

	@override
	List<Object> get props => [rewards, claimedRewards, points];
}
