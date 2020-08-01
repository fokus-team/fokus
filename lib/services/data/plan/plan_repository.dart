import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';

abstract class PlanRepository {
	Future<List<Plan>> getPlans({ObjectId caregiverId, ObjectId childId, List<String> fields = const [], bool activeOnly = true, bool oneDayOnly = false});
	Future<List<Plan>> getChildPlanInstances(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false});
	Future<PlanInstance> getActiveChildPlanInstance(ObjectId childId);
	Future<List<PlanInstance>> getPlanInstancesForPlans(ObjectId childId, List<ObjectId> planIDs, [Date date]);
	Future<List<PlanInstance>> getPastNotCompletedPlanInstances(ObjectId childId, List<ObjectId> planIDs, Date beforeDate, {List<String> fields = const []});

	Future updatePlanInstances(List<ObjectId> ids, {PlanInstanceState state, TimeDate start, TimeDate end});
}
