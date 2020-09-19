import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/db/date_span.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';

abstract class PlanRepository {
	Future<Plan> getPlan({ObjectId id, List<String> fields});
	Future<List<Plan>> getPlans({List<ObjectId> ids, ObjectId caregiverId, ObjectId childId, bool active, bool oneDayOnly = false, List<String> fields});

	Future<PlanInstance> getPlanInstance({ObjectId id, List<String> fields});
	Future<List<PlanInstance>> getPlanInstances({List<ObjectId> childIDs, PlanInstanceState state, List<ObjectId> planIDs, Date date, DateSpan<Date> between});

	Future<bool> getActiveChildPlanInstance(ObjectId childId);
	Future<List<PlanInstance>> getPlanInstancesForPlans(ObjectId childId, List<ObjectId> planIDs, [Date date]);
	Future<List<PlanInstance>> getPastNotCompletedPlanInstances(List<ObjectId> childIDs, List<ObjectId> planIDs, Date beforeDate, {List<String> fields});

	Future updatePlanInstances(ObjectId instanceId, {PlanInstanceState state, DateSpanUpdate<TimeDate> durationChange, List<ObjectId> taskInstances});
	Future updatePlanInstance(PlanInstance planInstance);

	Future updateMultiplePlanInstances(List<PlanInstance> planInstances);

	Future createPlanInstances(List<PlanInstance> plans);
	Future updatePlan(Plan plan);
	Future createPlan(Plan plan);
}
