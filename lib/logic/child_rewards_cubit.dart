import 'package:flutter/widgets.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/child_reward.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/services/data/data_repository.dart';

class ChildRewardsCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

  ChildRewardsCubit(this._activeUser, ModalRoute pageRoute) : super(pageRoute);

  void doLoadData() async {
	  var child = _activeUser();
		var caregiver = await _dataRepository.getUser(connected: child.id, role: UserRole.caregiver);
		List<Reward> rewards = [];
		if(caregiver != null) 
			rewards = await _dataRepository.getRewards(caregiverId: caregiver.id);
		List<ChildReward> claimedRewards = await _dataRepository.getChildRewards(childId: child.id);
	  emit(ChildRewardsLoadSuccess(
			rewards.map((reward) => UIReward.fromDBModel(reward)).toList(),
			claimedRewards.map((reward) => UIChildReward.fromDBModel(reward)).toList(),
			(child as UIChild).points
		));
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
