import 'package:flutter/widgets.dart';
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/gamification/child_reward.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChildRewardsCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authBloc;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

  ChildRewardsCubit(this._activeUser, ModalRoute pageRoute, this._authBloc) : super(pageRoute);

	Map<ObjectId, int> _claimedRewardsCount(List<UIChildReward> rewards) {
		Map<ObjectId, int> claimedCount = Map<ObjectId, int>();
		rewards.forEach((element) => claimedCount[element.id] = !claimedCount.containsKey(element.id) ? 1 : claimedCount[element.id] + 1);
		return claimedCount;
	}

  void doLoadData() async {
	  UIChild child = _activeUser();
		ObjectId caregiverID = child.connections.first;

		List<Reward> rewards = [];
		if(caregiverID != null) 
			rewards = await _dataRepository.getRewards(caregiverId: caregiverID);

	  emit(ChildRewardsLoadSuccess(
			rewards.map((reward) => UIReward.fromDBModel(reward)).where((reward) => reward.limit != null ? reward.limit < (_claimedRewardsCount(child.rewards)[reward.id] ?? 0) : true).toList(),
			child.rewards,
			child.points
		));
  }

	void claimReward(UIReward reward) async {
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
			await _dataRepository.claimChildReward(child.id, reward: model, points: points.map((e) =>
				Points.fromUICurrency(UICurrency(type: e.type, title: e.title), e.quantity, creator: e.createdBy)).toList()
			);
			_authBloc.add(AuthenticationActiveUserUpdated(child.copyWith(points: points, rewards: rewards..add(UIChildReward.fromDBModel(model)))));
			emit(ChildRewardsLoadSuccess(
				(state as ChildRewardsLoadSuccess).rewards.where((reward) => reward.limit != null ? reward.limit < (_claimedRewardsCount(child.rewards)[reward.id] ?? 0) : true).toList(),
				rewards..add(UIChildReward.fromDBModel(model)),
				points
			));
		}
	}

}

class ChildRewardsLoadSuccess extends DataLoadSuccess {
	final List<UIReward> rewards;
	final List<UIChildReward> claimedRewards;
	final List<UIPoints> points;

	ChildRewardsLoadSuccess(this.rewards, this.claimedRewards, this.points);

	@override
	List<Object> get props => [rewards, claimedRewards, points];
}
