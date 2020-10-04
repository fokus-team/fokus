import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/child_badge.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/gamification/reward.dart';

abstract class AwardRepository {
	Future<Reward> getReward({ObjectId id});
	Future<List<Reward>> getRewards({ObjectId caregiverId});
	Future<List<Badge>> getBadges({ObjectId caregiverId});

	Future updateReward(Reward reward);
	Future createReward(Reward reward);
	Future removeRewards({ObjectId id, ObjectId createdBy});

	Future createBadge(ObjectId userId, Badge badge);
	Future removeBadge(ObjectId userId, Badge badge);

	Future<List<ChildBadge>> getChildBadges({ObjectId childId});

}
