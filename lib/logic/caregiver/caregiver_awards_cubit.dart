import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';

class CaregiverAwardsCubit extends StatefulCubit {
	final ActiveUserFunction _activeUser;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverAwardsCubit(this._activeUser, pageRoute) : super(pageRoute, options: [StatefulOption.resetSubmissionState]);

  @override
	Future doLoadData() async {
    UICaregiver user = _activeUser();
    var rewards = await _dataRepository.getRewards(caregiverId: user.id);
		
		emit(CaregiverAwardsState(
			rewards: rewards.map((reward) => UIReward.fromDBModel(reward)).toList(),
			badges: List.from(user.badges)
		));
  }

	void removeReward(ObjectId id) async {
		if (!beginSubmit())
			return;
		CaregiverAwardsState state = this.state;
		await _dataRepository.removeRewards(id: id);
		emit(RewardRemovedState(
			rewards: state.rewards.where((element) => element.id != id).toList(),
			badges: state.badges
		));
	}

	void removeBadge(UIBadge badge) async {
		if (!beginSubmit())
			return;
    UICaregiver user = _activeUser();
		Badge model = Badge(name: badge.name, description: badge.description, icon: badge.icon);
		await _dataRepository.removeBadge(user.id, model);
		emit(BadgeRemovedState(
			badges: List.from(user.badges..remove(UIBadge.fromDBModel(model))),
			rewards: (state as CaregiverAwardsState).rewards
		));
	}
}

class CaregiverAwardsState extends StatefulState {
	final List<UIReward> rewards;
	final List<UIBadge> badges;

	CaregiverAwardsState({this.rewards, this.badges, DataSubmissionState submissionState}) : super.loaded(submissionState);

	@override
  StatefulState withSubmitState(DataSubmissionState submissionState) => CaregiverAwardsState(rewards: rewards, badges: badges, submissionState: submissionState);

  @override
	List<Object> get props => super.props..addAll([rewards, badges]);
}

class RewardRemovedState extends CaregiverAwardsState {
	RewardRemovedState({List<UIReward> rewards, List<UIBadge> badges}) : super(rewards: rewards, badges: badges, submissionState: DataSubmissionState.submissionSuccess);
}
class BadgeRemovedState extends CaregiverAwardsState {
	BadgeRemovedState({List<UIReward> rewards, List<UIBadge> badges}) : super(rewards: rewards, badges: badges, submissionState: DataSubmissionState.submissionSuccess);
}

