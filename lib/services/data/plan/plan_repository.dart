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
	Future<List<Plan>> getPlans({ObjectId caregiverId, ObjectId childId, bool activeOnly = true, bool oneDayOnly = false, List<String> fields});
	Future<List<PlanInstance>> getPlanInstances({ObjectId childId, PlanInstanceState state, List<ObjectId> planIDs, Date date, DateSpan<Date> between});

	Future<bool> getActiveChildPlanInstance(ObjectId childId);
	Future<List<PlanInstance>> getPlanInstancesForPlans(ObjectId childId, List<ObjectId> planIDs, [Date date]);
	Future<List<PlanInstance>> getPastNotCompletedPlanInstances(List<ObjectId> childIDs, List<ObjectId> planIDs, Date beforeDate, {List<String> fields});

	Future updatePlanInstances(ObjectId instanceId, {PlanInstanceState state, DateSpanUpdate<TimeDate> durationChange});
	Future updatePlan(Plan plan);
	Future createPlan(Plan plan);
}
