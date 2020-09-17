import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/gamification/reward.dart';

abstract class AwardRepository {
	Future<Reward> getReward({ObjectId id});
	Future<List<Reward>> getRewards({ObjectId caregiverId});

	Future updateReward(Reward reward);
	Future createReward(Reward reward);
	Future removeReward(ObjectId id);
}
