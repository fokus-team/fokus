import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';

abstract class PlanRepository {
	Future<List<Plan>> getChildPlans(ObjectId childId, {bool activeOnly = true});
	Future<List<Plan>> getChildPlanInstances(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false});
	Future<bool> childActivePlanInstanceExists(ObjectId childId);
}
