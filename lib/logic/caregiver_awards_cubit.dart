import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';

class CaregiverAwardsCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverAwardsCubit(this._activeUser, pageRoute) : super(pageRoute);

  @override
	doLoadData() async {
    var user = _activeUser();
    var rewards = await _dataRepository.getRewards(caregiverId: user.id);
		
		emit(CaregiverAwardsLoadSuccess(
			rewards.map((reward) => UIReward.fromDBModel(reward)).toList(),
			(user as UICaregiver).badges
		));
  }
}

class CaregiverAwardsLoadSuccess extends DataLoadSuccess {
	final List<UIReward> rewards;
	final List<UIBadge> badges;

	CaregiverAwardsLoadSuccess(this.rewards, this.badges);

	@override
	List<Object> get props => [rewards, badges];
}

