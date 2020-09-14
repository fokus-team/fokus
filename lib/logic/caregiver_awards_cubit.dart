import 'package:fokus/model/ui/gamification/ui_reward.dart';
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
    var caregiverId = _activeUser().id;
    var rewards = await _dataRepository.getRewards(caregiverId: caregiverId);
		emit(CaregiverAwardsLoadSuccess(rewards.map((reward) => UIReward.fromDBModel(reward)).toList()));
  }
}

class CaregiverAwardsLoadSuccess extends DataLoadSuccess {
	final List<UIReward> rewards;

	CaregiverAwardsLoadSuccess(this.rewards);

	@override
	List<Object> get props => [rewards];
}

