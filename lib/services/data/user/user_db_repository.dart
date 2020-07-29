import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin UserDbRepository implements DbRepository {
	Future<User> getUser([SelectorBuilder selector]) {
		return dbClient.queryOneTyped(Collection.user, selector, (json) => User.typedFromJson(json));
	}

	Future<Map<ObjectId, String>> getUserNames(List<ObjectId> users) {
		var query = where.oneFrom('_id', users).fields(['name', '_id']);
		return dbClient.queryTypedMap(Collection.user, query, (json) => MapEntry(json['_id'], json['name']));
	}

	Future<List<Child>> getCaregiverChildren(ObjectId caregiverId) {
		var query = where.eq('role', UserRole.child.index).and(where.eq('connections', caregiverId));
		return dbClient.queryTyped(Collection.user, query, (json) => Child.fromJson(json));
	}

	Future<User> getUserById(ObjectId id) => getUser(where.eq('_id', id));
	// Temporary until we have a login page
	Future<User> getUserByRole(UserRole role) => getUser(where.eq('role', role.index));
}
