
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CaregiverAwardsCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authBloc;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverAwardsCubit(this._activeUser, pageRoute, this._authBloc) : super(pageRoute);

  @override
	void doLoadData() async {
    var user = _activeUser();
    var rewards = await _dataRepository.getRewards(caregiverId: user.id);
		
		emit(CaregiverAwardsLoadSuccess(
			rewards.map((reward) => UIReward.fromDBModel(reward)).toList(),
			(user as UICaregiver).badges
		));
  }

	void removeReward(ObjectId id) async {
		await _dataRepository.removeReward(id);
		doLoadData();
	}

	void removeBadge(UIBadge badge) async {
    UICaregiver user = _activeUser();
		Badge model = Badge(name: badge.name, description: badge.description, icon: badge.icon);
		await _dataRepository.removeBadge(user.id, model);
		_authBloc.add(AuthenticationActiveUserUpdated(user.copyWith(badges: user.badges..remove(UIBadge.fromDBModel(model)))));
	}
	
}

class CaregiverAwardsLoadSuccess extends DataLoadSuccess {
	final List<UIReward> rewards;
	final List<UIBadge> badges;

	CaregiverAwardsLoadSuccess(this.rewards, this.badges);

	@override
	List<Object> get props => [rewards, badges];
}

