import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';

abstract class DataRepository {
	Future initialize();

	Future<User> getUser([SelectorBuilder selector]);
	Future<Map<ObjectId, String>> getUserNames(List<ObjectId> users);
	Future<List<Child>> getCaregiverChildren(ObjectId caregiverId);

	// Temporary until we have a login page
	Future<User> getUserById(ObjectId id);
	Future<User> getUserByRole(UserRole role);

	Future<List<Plan>> getChildPlans(ObjectId childId, {bool activeOnly = true});
	Future<List<Plan>> getChildPlanInstances(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false});
	Future<bool> childActivePlanInstanceExists(ObjectId childId);
}
