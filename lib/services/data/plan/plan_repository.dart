import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/db/date_span.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';

abstract class PlanRepository {
	Future<Plan> getPlan({required ObjectId id, List<String>? fields});
	Future<List<Plan>> getPlans({List<ObjectId>? ids, ObjectId? caregiverId, ObjectId? childId, bool? active, bool? untilCompleted, List<String>? fields});
	Future<int> countPlans({List<ObjectId>? ids, ObjectId? caregiverId, ObjectId? childId, bool? active, bool? untilCompleted});

	Future<PlanInstance> getPlanInstance({ObjectId? id, ObjectId? childId, PlanInstanceState? state, List<String>? fields});
	Future<List<PlanInstance>> getPlanInstances({List<ObjectId>? childIDs, PlanInstanceState? state, ObjectId? planId, Date? date, DateSpan<Date>? between, List<String>? fields});

	Future<bool> hasActiveChildPlanInstance(ObjectId childId);
	Future<List<PlanInstance>> getPlanInstancesForPlans(ObjectId childId, List<ObjectId> planIDs, [Date? date]);
	Future<List<PlanInstance>> getPastNotCompletedPlanInstances(List<ObjectId> childIDs, List<ObjectId> planIDs, Date beforeDate, {List<String>? fields});

	Future updatePlanInstanceFields(ObjectId instanceId, {PlanInstanceState? state, DateSpanUpdate<TimeDate>? durationChange, List<ObjectId>? taskInstances, List<DateSpan<TimeDate>>? duration});
	Future updatePlanInstance(PlanInstance planInstance);
	Future updatePlanFields(List<ObjectId> planIDs, {ObjectId? assign, ObjectId? unassign});

	Future updateMultiplePlanInstances(List<PlanInstance> planInstances);

	Future updateActivePlanInstanceState(ObjectId childId, PlanInstanceState state);

	Future createPlanInstances(List<PlanInstance> plans);
	Future updatePlan(Plan plan);
	Future createPlan(Plan plan);

	Future removePlans({List<ObjectId>? ids, ObjectId? caregiverId});
	Future removePlanInstances({ObjectId? planId, List<ObjectId>? ids, List<ObjectId>? childIds});
}
