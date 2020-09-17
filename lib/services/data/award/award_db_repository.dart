import 'package:fokus/model/db/gamification/badge.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin AwardDbRepository implements DbRepository {
	Future<Reward> getReward({ObjectId id}) {
		var query = where.eq('_id', id);
		return dbClient.queryOneTyped(Collection.reward, query, (json) => Reward.fromJson(json));
	}

	Future<List<Reward>> getRewards({ObjectId caregiverId}) {
		var query = where.eq('createdBy', caregiverId);
		return dbClient.queryTyped(Collection.reward, query, (json) => Reward.fromJson(json));
	}
	
	Future updateReward(Reward reward) => dbClient.update(Collection.reward, where.eq('_id', reward.id), reward.toJson(), multiUpdate: false);
	Future createReward(Reward reward) => dbClient.insert(Collection.reward, reward.toJson());
	Future removeReward(ObjectId id) => dbClient.remove(Collection.reward, id);

}
