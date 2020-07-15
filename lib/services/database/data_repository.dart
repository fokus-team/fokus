import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/database/mongo_client.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DataRepository {
	final MongoClient client = MongoClient();

	Future<DataRepository> initialize(String config) async {
		await client.initialize(config);
		return this;
	}

	Future<User> getUser([SelectorBuilder selector]) async {
		return client.queryOne(Collection.user, selector).then((response) => User.typedFromJson(response));
	}

	Future<List<Child>> getCaregiverChildren(ObjectId caregiverId) {
		var query = where.eq('role', UserRole.child.index).and(where.eq('connections', caregiverId));
		return client.query(Collection.user, query).then((children) => children.map((child) => Child.fromJson(child)).toList());
	}

	// Temporary until we have a login page
	Future<User> getUserById(ObjectId id) async => getUser(where.eq('_id', id));
	Future<User> getUserByRole(UserRole role) async => getUser(where.eq('role', role.index));
}
