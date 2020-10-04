import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin UserDbRepository implements DbRepository {
	final Logger _logger = Logger('UserDbRepository');

	Future<User> getUser({ObjectId id, ObjectId connected, String authenticationId, String notificationId, UserRole role, List<String> fields}) {
		var query = _buildUserQuery(id: id, connected: connected, authenticationId: authenticationId, notificationId: notificationId, role: role);
		if (fields != null && !fields.contains('role'))
			fields.add('role');
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.user, query, (json) => User.typedFromJson(json));
	}

	Future<List<User>> getUsers({List<ObjectId> ids, ObjectId connected, UserRole role, List<String> fields}) {
		var query = _buildUserQuery(ids: ids, connected: connected, role: role);
		if (fields != null && !fields.contains('role'))
			fields.add('role');
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.user, query, (json) => User.typedFromJson(json));
	}

	Future<Map<ObjectId, String>> getUserNames(List<ObjectId> users) {
		var query = where.oneFrom('_id', users).fields(['name', '_id']);
		return dbClient.queryTypedMap(Collection.user, query, (json) => MapEntry(json['_id'], json['name']));
	}

	Future<bool> userExists({ObjectId id, UserRole role}) => dbClient.exists(Collection.user, _buildUserQuery(id: id, role: role));

	Future createUser(User user) => dbClient.insert(Collection.user, user.toJson());

	Future updateUser(ObjectId userId, {List<ObjectId> newConnections, String locale}) {
		var document = modify;
		if (newConnections != null)
			document.addAllToSet('connections', newConnections);
		if (locale != null)
			locale.isNotEmpty ? document.set('locale',  locale) : document.unset('locale');
		return dbClient.update(Collection.user, where.eq('_id', userId), document);
	}

	Future insertNotificationID(ObjectId userId, String notificationId) {
		return dbClient.update(Collection.user, _buildUserQuery(id: userId), modify.addToSet('notificationIDs', notificationId));
	}
	Future removeNotificationID(String notificationID, {ObjectId userId}) {
		return dbClient.update(Collection.user, _buildUserQuery(id: userId), modify.pull('notificationIDs', notificationID));
	}

	SelectorBuilder _buildUserQuery({List<ObjectId> ids, ObjectId id, ObjectId connected, String authenticationId, String notificationId, UserRole role}) {
		SelectorBuilder query = where;
		if (ids != null && id != null)
			_logger.warning("Both ID and ID list specified in user query");

		if (ids != null)
			query.oneFrom('_id', ids);
		if (id != null)
			query.eq('_id', id);
		if (notificationId != null)
			query.eq('notificationIDs', notificationId);
		if (authenticationId != null)
			query.eq('authenticationID', authenticationId);
		if (connected != null)
			query.eq('connections', connected);
		if (role != null)
			query.eq('role', role.index);
		if (query.map.isEmpty)
			return null;
		return query;
	}
}
