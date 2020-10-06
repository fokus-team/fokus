import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/child_badge.dart';
import 'package:fokus/model/db/gamification/child_reward.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/gamification/reward.dart';

abstract class AwardRepository {
	Future<Reward> getReward({ObjectId id});
	Future<List<Reward>> getRewards({ObjectId caregiverId});

	Future claimChildReward(ObjectId childId, {ChildReward reward, List<Points> points});

	Future updateReward(Reward reward);
	Future createReward(Reward reward);
	Future removeReward(ObjectId id);

	Future createBadge(ObjectId userId, Badge badge);
	Future removeBadge(ObjectId userId, Badge badge);

	Future<List<ChildBadge>> getChildBadges({ObjectId childId});

}
