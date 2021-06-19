import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../model/db/date/time_date.dart';
import '../../model/db/gamification/child_reward.dart';
import '../../model/db/gamification/points.dart';
import '../../model/db/gamification/reward.dart';
import '../../model/db/user/child.dart';
import '../../model/notification/notification_type.dart';
import '../../services/analytics_service.dart';
import '../../services/data/data_repository.dart';
import '../../services/notifications/notification_service.dart';
import '../common/cubit_base.dart';

class ChildRewardsCubit extends CubitBase<ChildRewardsData> {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();

	List<Reward>? _rewards;

  ChildRewardsCubit(ModalRoute pageRoute) : super(pageRoute, options: [StatefulOption.resetSubmissionState]);

  @override
  Future loadData() => load(body: () async {
	  if (activeUser == null) return null;
		var caregiverID = activeUser!.connections?.first;
		if(caregiverID != null && _rewards == null)
			_rewards = await _dataRepository.getRewards(caregiverId: caregiverID);
	  return _refreshRewardState();
  });

	Future claimReward(Reward reward) => submit(body: () async {
		var user = activeUser as Child;
		var rewards = user.rewards!;
		var model = ChildReward(
			id: reward.id,
			name: reward.name,
			cost: reward.cost,
			icon: reward.icon,
			date: TimeDate.now()
		);
		var pointCurrency = user.points!.firstWhereOrNull((element) => element.type == reward.cost!.type);

		if (pointCurrency != null && pointCurrency.quantity! >= reward.cost!.quantity!) {
			user.points![user.points!.indexOf(pointCurrency)] = pointCurrency.copyWith(quantity: pointCurrency.quantity! - reward.cost!.quantity!);
			rewards.add(model);
			await _dataRepository.claimChildReward(user.id!, reward: model, points: user.points!);
			_analyticsService.logRewardBought(reward);
			await _notificationService.sendRewardBoughtNotification(model.id!, model.name!, user.connections!.first, user);
		}
		return _refreshRewardState();
	});

	ChildRewardsData _refreshRewardState() {
		var child = activeUser as Child;
		var claimedCount = <ObjectId, int>{};
		child.rewards!.forEach((element) => claimedCount[element.id!] = !claimedCount.containsKey(element.id) ? 1 : claimedCount[element.id]! + 1);
		return ChildRewardsData(
			rewards: _rewards!.where((reward) => reward.limit != null ? reward.limit! > (claimedCount[reward.id] ?? 0) : true).toList(),
			claimedRewards: List.from(child.rewards!),
			points: List.from(child.points!),
		);
	}

	@override
	List<NotificationType> notificationTypeSubscription() => [NotificationType.taskApproved];
}

class ChildRewardsData extends Equatable {
	final List<Reward> rewards;
	final List<ChildReward> claimedRewards;
	final List<Points> points;

	ChildRewardsData({
		required this.rewards,
		required this.claimedRewards,
		required this.points,
	});

  @override
	List<Object?> get props => [rewards, claimedRewards, points];
}
