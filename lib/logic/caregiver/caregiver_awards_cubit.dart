import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../model/db/gamification/badge.dart';
import '../../model/db/gamification/reward.dart';
import '../../model/db/user/caregiver.dart';
import '../../services/data/data_repository.dart';
import '../common/cubit_base.dart';

class CaregiverAwardsCubit extends CubitBase<CaregiverAwardsData> {
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverAwardsCubit(pageRoute) : super(pageRoute, options: [StatefulOption.resetSubmissionState]);

  @override
	Future loadData() => load(body: () async {
	  if (activeUser == null) return null;
    var user = activeUser as Caregiver;
		return CaregiverAwardsData(
			rewards: await _dataRepository.getRewards(caregiverId: user.id!),
			badges: List.from(user.badges!)
		);
  });

	Future removeReward(ObjectId id) => submit(body: () async {
		await _dataRepository.removeRewards(id: id);
		return CaregiverAwardsData(
			rewards: state.data!.rewards.where((element) => element.id != id).toList(),
			badges: state.data!.badges
		);
	});

	Future removeBadge(Badge badge) => submit(body: () async {
		var user = activeUser as Caregiver;
		var model = Badge(name: badge.name, description: badge.description, icon: badge.icon);
		await _dataRepository.removeBadge(user.id!, model);
		return CaregiverAwardsData(
			badges: List.from(user.badges!..remove(model)),
			rewards: state.data!.rewards
		);
	});
}

enum RemovedType {
	badge, reward
}

class CaregiverAwardsData extends Equatable {
	final List<Reward> rewards;
	final List<Badge> badges;
	final RemovedType? removedType;

	CaregiverAwardsData({required this.rewards, required this.badges, this.removedType});

  @override
	List<Object?> get props => [rewards, badges, removedType];
}
