import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/child_badge.dart';
import 'package:fokus/model/db/gamification/child_reward.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin AwardDbRepository implements DbRepository {
	Future<Reward> getReward({ObjectId id}) {
		var query = _buildRewardQuery(id: id);
		return dbClient.queryOneTyped(Collection.reward, query, (json) => Reward.fromJson(json));
	}

	Future<List<Reward>> getRewards({ObjectId caregiverId}) {
		var query = _buildRewardQuery(caregiverId: caregiverId);
		return dbClient.queryTyped(Collection.reward, query, (json) => Reward.fromJson(json));
	}

	Future<List<ChildReward>> getChildRewards({ObjectId childId}) {
		var query = _buildUserQuery(id: childId);
		return dbClient.queryOneTyped(Collection.user, query, (json) => (Child.fromJson(json)).rewards);
	}
	
	Future updateReward(Reward reward) => dbClient.update(Collection.reward, _buildRewardQuery(id: reward.id), reward.toJson(), multiUpdate: false);
	Future createReward(Reward reward) => dbClient.insert(Collection.reward, reward.toJson());
	Future removeReward(ObjectId id) => dbClient.remove(Collection.reward, _buildRewardQuery(id: id));

	Future<List<Badge>> getBadges({ObjectId caregiverId}) {
		var query = _buildUserQuery(id: caregiverId);
		return dbClient.queryOneTyped(Collection.user, query, (json) => (Caregiver.fromJson(json)).badges);
	}

	Future claimChildReward(ObjectId childId, {ChildReward reward, List<Points> points}) {
		var document = modify;
		if (reward != null)
			document.push('rewards', reward.toJson());
		if (points != null)
			document.set('points', points.map((e) => e.toJson()).toList());
		return dbClient.update(Collection.user, _buildUserQuery(id: childId), document);
	}

	Future createBadge(ObjectId userId, Badge badge) {
		var document = modify;
		if (badge != null)
			document.push('badges', badge.toJson());
		return dbClient.update(Collection.user, _buildUserQuery(id: userId), document);
	}

	Future removeBadge(ObjectId userId, Badge badge) {
		var document = modify;
		if (badge != null)
			document.pull('badges', badge.toJson());
		return dbClient.update(Collection.user, _buildUserQuery(id: userId), document);
	}

	Future<List<ChildBadge>> getChildBadges({ObjectId childId}) {
		var query = _buildUserQuery(id: childId);
		return dbClient.queryOneTyped(Collection.user, query, (json) => (Child.fromJson(json)).badges);
	}

	SelectorBuilder _buildRewardQuery({ObjectId id, ObjectId caregiverId}) {
		SelectorBuilder query = where;
		if (id != null)
			query.eq('_id', id);
		if (caregiverId != null)
			query.eq('createdBy', caregiverId);
		return query;
	}

	SelectorBuilder _buildUserQuery({ObjectId id}) {
		SelectorBuilder query = where;
		if (id != null)
			query.eq('_id', id);
		return query;
	}

}
