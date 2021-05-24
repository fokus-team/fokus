import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/child_reward.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/gamification/reward.dart';

abstract class AwardRepository {
	Future<Reward?> getReward({required ObjectId id});
	Future<List<Reward>> getRewards({required ObjectId caregiverId});
	Future<int> countRewards({required ObjectId caregiverId});

	Future updateReward(Reward reward);
	Future createReward(Reward reward);
	Future removeRewards({ObjectId? id, ObjectId? createdBy});
	Future claimChildReward(ObjectId childId, {ChildReward? reward, List<Points>? points});

	Future createBadge(ObjectId userId, Badge? badge);
	Future removeBadge(ObjectId userId, Badge? badge);
}
