import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class UserRepository {
	Future<User> getUser({ObjectId id, ObjectId connected, String authenticationId, UserRole role, List<String> fields});

	Future<Map<ObjectId, String>> getUserNames(List<ObjectId> users);
	Future<List<Child>> getCaregiverChildren(ObjectId caregiverId, [List<String> fields]);

	Future createUser(User user);
}
