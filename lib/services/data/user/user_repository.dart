import 'package:fokus/model/db/gamification/child_badge.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class UserRepository {
	Future<User> getUser({ObjectId? id, ObjectId? connected, String? authenticationId, String? notificationId, UserRole? role, List<String>? fields});
	Future<List<User>> getUsers({List<ObjectId>? ids, ObjectId? connected, UserRole? role, List<String>? fields});

	Future<Map<ObjectId, String>> getUserNames(List<ObjectId> users);
	Future<bool> userExists({required ObjectId id, UserRole? role});

	Future createUser(User user);
	Future updateUser(ObjectId userId, {List<ObjectId>? newConnections, List<ObjectId>? removedConnections, 
		List<ChildBadge>? badges, String? name, String? locale, List<Points>? points, List<ObjectId>? friends});
	Future removeUsers(List<ObjectId> ids);

	Future insertNotificationID(ObjectId userId, String notificationId);
	Future removeNotificationID(String notificationID, {ObjectId? userId});
}
