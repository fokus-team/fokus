import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin UserDbRepository implements DbRepository {
	Future<User> getUser({ObjectId id, ObjectId connected, UserRole role, List<String> fields}) {
		var query = _buildUserQuery(id: id, connected: connected, role: role);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.user, query, (json) => User.typedFromJson(json));
	}

	Future<Map<ObjectId, String>> getUserNames(List<ObjectId> users) {
		var query = where.oneFrom('_id', users).fields(['name', '_id']);
		return dbClient.queryTypedMap(Collection.user, query, (json) => MapEntry(json['_id'], json['name']));
	}

	Future<List<Child>> getCaregiverChildren(ObjectId caregiverId, [List<String> fields]) {
		var query = where.eq('role', UserRole.child.index).and(where.eq('connections', caregiverId));
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.user, query, (json) => Child.fromJson(json));
	}

	Future createUser(User user) => dbClient.insert(Collection.user, user.toJson());

	SelectorBuilder _buildUserQuery({ObjectId id, ObjectId connected, UserRole role}) {
		SelectorBuilder query;
		var addExpression = (expression) => query == null ? (query = expression) : query.and(expression);
		if (id != null)
			addExpression(where.eq('_id', id));
		if (connected != null)
			addExpression(where.eq('connections', connected));
		if (role != null)
			addExpression(where.eq('role', role.index));
		return query;
	}
}
