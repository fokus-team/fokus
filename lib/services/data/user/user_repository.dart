import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class UserRepository {
	Future<User> getUser([SelectorBuilder selector]);
	Future<Map<ObjectId, String>> getUserNames(List<ObjectId> users);
	Future<List<Child>> getCaregiverChildren(ObjectId caregiverId, [List<String> fields = const []]);

	Future<User> getUserById(ObjectId id);
	// Temporary until we have a login page
	Future<User> getUserByRole(UserRole role);
}
