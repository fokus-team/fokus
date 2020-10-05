import 'package:flutter/widgets.dart';
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/gamification/child_reward.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
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

  void doLoadData() async {
	  var child = _activeUser();
		var caregiver = await _dataRepository.getUser(connected: child.id, role: UserRole.caregiver);

		List<Reward> rewards = [];
		if(caregiver != null) 
			rewards = await _dataRepository.getRewards(caregiverId: caregiver.id);

		List<ChildReward> claimedRewards = await _dataRepository.getChildRewards(childId: child.id);
		Map<ObjectId, int> claimedCount = Map<ObjectId, int>();
		claimedRewards.forEach((element) => claimedCount[element.id] = !claimedCount.containsKey(element.id) ? 1 : claimedCount[element.id] + 1);

	  emit(ChildRewardsLoadSuccess(
			rewards.map((reward) => UIReward.fromDBModel(reward)).where((reward) => reward.limit != null ? reward.limit < (claimedCount[reward.id] ?? 0) : true).toList(),
			claimedRewards.map((reward) => UIChildReward.fromDBModel(reward)).toList(),
			(child as UIChild).points
		));
  }

	void claimReward(UIReward reward) async {
    UIChild child = _activeUser();
		Map<CurrencyType, int> points = child.points;
		ChildReward model = ChildReward(
			id: reward.id,
			name: reward.name, 
			cost: Points.fromUIPoints(reward.cost),
			icon: reward.icon,
			date: TimeDate.now()
		);

		if(points[reward.cost.type] >= reward.cost.quantity) {
			points[reward.cost.type] -= reward.cost.quantity;
			await _dataRepository.updateUser(child.id, points: points.entries.map((e) =>
				Points.fromUICurrency(UICurrency(type: e.key, title: child.pointsNames[e.key]), e.value)).toList()
			);
			_authBloc.add(AuthenticationActiveUserUpdated(child.copyWith(points: points)));
			await _dataRepository.createChildReward(child.id, model).then((value) => doLoadData());
		}
	}

}

class ChildRewardsLoadSuccess extends DataLoadSuccess {
	final List<UIReward> rewards;
	final List<UIChildReward> claimedRewards;
	final Map<CurrencyType, int> points;

	ChildRewardsLoadSuccess(this.rewards, this.claimedRewards, this.points);

	@override
	List<Object> get props => [rewards, claimedRewards, points];
}
