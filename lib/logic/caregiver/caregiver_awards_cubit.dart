import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/db/user/caregiver.dart';

class CaregiverAwardsCubit extends StatefulCubit {
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverAwardsCubit(pageRoute) : super(pageRoute, options: [StatefulOption.resetSubmissionState]);

  @override
	Future doLoadData() async {
    Caregiver user = activeUser as Caregiver;
		emit(CaregiverAwardsState(
			rewards: await _dataRepository.getRewards(caregiverId: user.id!),
			badges: List.from(user.badges!)
		));
  }

	void removeReward(ObjectId id) async {
		if (!beginSubmit())
			return;
		var state = this.state as CaregiverAwardsState;
		await _dataRepository.removeRewards(id: id);
		emit(RewardRemovedState(
			rewards: state.rewards.where((element) => element.id != id).toList(),
			badges: state.badges
		));
	}

	void removeBadge(Badge badge) async {
		if (!beginSubmit())
			return;
		var user = activeUser as Caregiver;
		Badge model = Badge(name: badge.name, description: badge.description, icon: badge.icon);
		await _dataRepository.removeBadge(user.id!, model);
		emit(BadgeRemovedState(
			badges: List.from(user.badges!..remove(model)),
			rewards: (state as CaregiverAwardsState).rewards
		));
	}
}

class CaregiverAwardsState extends StatefulState {
	final List<Reward> rewards;
	final List<Badge> badges;

	CaregiverAwardsState({required this.rewards, required this.badges, DataSubmissionState? submissionState}) : super.loaded(submissionState);

	@override
  StatefulState withSubmitState(DataSubmissionState submissionState) => CaregiverAwardsState(rewards: rewards, badges: badges, submissionState: submissionState);

  @override
	List<Object?> get props => super.props..addAll([rewards, badges]);
}

class RewardRemovedState extends CaregiverAwardsState {
	RewardRemovedState({required List<Reward> rewards, required List<Badge> badges})
			: super(rewards: rewards, badges: badges, submissionState: DataSubmissionState.submissionSuccess);
}
class BadgeRemovedState extends CaregiverAwardsState {
	BadgeRemovedState({required List<Reward> rewards, required List<Badge> badges})
			: super(rewards: rewards, badges: badges, submissionState: DataSubmissionState.submissionSuccess);
}

