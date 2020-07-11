import 'package:fokus/data/model/collection.dart';
import 'package:fokus/data/model/user/user.dart';
import 'package:fokus/data/model/user/user_role.dart';
import 'package:fokus/data/repository/database/mongo_client.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DataRepository {
	final MongoClient client = MongoClient();

	Future<DataRepository> initialize(String config) async {
		await client.initialize(config);
		return this;
	}

	Future<User> fetchUser([SelectorBuilder selector]) async {
		return client.query(Collection.user, selector).then((response) => User.typedFromJson(response));
	}

	// Temporary until we have a login page
	Future<User> fetchUserById(ObjectId id) async => fetchUser(where.eq('_id', id));
	Future<User> fetchUserByRole(UserRole role) async => fetchUser(where.eq('role', role.index));
}
