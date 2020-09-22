import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/user.dart';
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

	Future<List<Badge>> getBadges({ObjectId caregiverId}) {
		var query = where.eq('_id', caregiverId);
		return dbClient.queryOneTyped(Collection.user, query, (json) => (Caregiver.fromJson(json)).badges);
	}
	
	Future updateReward(Reward reward) => dbClient.update(Collection.reward, where.eq('_id', reward.id), reward.toJson(), multiUpdate: false);
	Future createReward(Reward reward) => dbClient.insert(Collection.reward, reward.toJson());
	Future removeReward(ObjectId id) => dbClient.remove(Collection.reward, id);

	Future createBadge(ObjectId userId, Badge badge) {
		var document = modify;
		if (badge != null)
			document.addToSet('badges', badge.toJson());
		return dbClient.update(Collection.user, where.eq('_id', userId), document);
	}

	Future removeBadge(ObjectId userId, Badge badge) {
		var document = modify;
		if (badge != null)
			document.pull('badges', badge.toJson());
		return dbClient.update(Collection.user, where.eq('_id', userId), document);
	}

}
