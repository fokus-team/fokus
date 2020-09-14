import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin AwardDbRepository implements DbRepository {
	Future<List<Reward>> getRewards({ObjectId caregiverId}) {
		var query = _buildAwardQuery(caregiverId: caregiverId);
		return dbClient.queryTyped(Collection.reward, query, (json) => Reward.fromJson(json));
	}
	
	SelectorBuilder _buildAwardQuery({ObjectId id, ObjectId caregiverId}) {
		SelectorBuilder query = where;
		if (id != null)
			query.eq('_id', id);
		if (caregiverId != null)
			query.eq('createdBy', caregiverId);
		return query;
	}
}
