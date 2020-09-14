import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/gamification/reward.dart';

abstract class AwardRepository {
	Future<List<Reward>> getAwards({ObjectId caregiverId});
}
