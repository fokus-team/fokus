import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/services/data/db/db_repository.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/db/date_span.dart';

mixin PlanDbRepository implements DbRepository {
	Future<Plan> getPlan({required ObjectId id, List<String>? fields}) {
		var query = _buildPlanQuery(id: id);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.plan, query, (json) => Plan.fromJson(json)!);
	}

	Future<List<Plan>> getPlans({List<ObjectId>? ids, ObjectId? caregiverId, ObjectId? childId, bool? active, bool? untilCompleted, List<String>? fields}) {
		var query = _buildPlanQuery(caregiverId: caregiverId, childId: childId, active: active, ids: ids);
		if (untilCompleted != null)
			query.and(where.eq('repeatability.untilCompleted', untilCompleted));
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.plan, query, (json) => Plan.fromJson(json)!);
	}

	Future<int> countPlans({List<ObjectId>? ids, ObjectId? caregiverId, ObjectId? childId, bool? active, bool? untilCompleted}) {
		var query = _buildPlanQuery(caregiverId: caregiverId, childId: childId, active: active, ids: ids);
		if (untilCompleted != null)
			query.and(where.eq('repeatability.untilCompleted', untilCompleted));
		return dbClient.count(Collection.plan, query);
	}

	Future<PlanInstance> getPlanInstance({ObjectId? id, ObjectId? childId, PlanInstanceState? state, List<String>? fields}) {
		var query = _buildPlanQuery(id: id, childId: childId, state: state);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json)!);
	}

	Future<List<PlanInstance>> getPlanInstances({List<ObjectId>? childIDs, PlanInstanceState? state, ObjectId? planId, Date? date, DateSpan<Date>? between, List<String>? fields}) {
		var query = _buildPlanQuery(childIDs: childIDs, state: state, date: date, between: between, planId: planId);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json)!);
	}

	Future<bool> hasActiveChildPlanInstance(ObjectId childId) {
		return dbClient.exists(Collection.planInstance, _buildPlanQuery(childId: childId, state: PlanInstanceState.active));
	}

	Future<List<PlanInstance>> getPlanInstancesForPlans(ObjectId childId, List<ObjectId> planIDs, [Date? date]) {
		var query = _buildPlanQuery(childId: childId, date: date).and(where.oneFrom('planID', planIDs));
		return dbClient.queryTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json)!);
	}

	Future<List<PlanInstance>> getPastNotCompletedPlanInstances(List<ObjectId> childIDs, List<ObjectId> planIDs, Date beforeDate, {List<String>? fields}) {
		var query = where.oneFrom('assignedTo', childIDs).and(where.oneFrom('planID', planIDs)).and(where.lt('date', beforeDate));
		query.and(where.ne('state', PlanInstanceState.completed.index)).and(where.ne('state', PlanInstanceState.lostForever.index));
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json)!);
	}

	Future updatePlanInstanceFields(ObjectId instanceId, {PlanInstanceState? state, DateSpanUpdate<TimeDate>? durationChange, List<ObjectId>? taskInstances, List<DateSpan<TimeDate>>? duration}) {
		var document = modify;
		if (state != null)
			document.set('state', state.index);
		if (durationChange != null)
			document.set('duration.${durationChange.getQuery()}', durationChange.value.toDBDate());
		if	(taskInstances != null)
			document.set('taskInstances', taskInstances);
		if (duration != null)
			document.set('duration', duration.map((v) => v.toJson()).toList());
		return dbClient.update(Collection.planInstance, where.eq('_id', instanceId), document);
	}

	Future updatePlanFields(List<ObjectId> planIDs, {ObjectId? assign, ObjectId? unassign}) {
		var query = (ObjectId id) => where.eq('_id', id);
		var planModify = modify;
		if (assign != null)
			planModify.addToSet('assignedTo', assign);
		if (unassign != null)
			planModify.pull('assignedTo', unassign);
		return dbClient.updateAll(Collection.plan, planIDs.map((id) => query(id)).toList(), List.filled(planIDs.length, planModify));
	}

	Future updatePlanInstance(PlanInstance planInstance) => dbClient.update(Collection.planInstance, _buildPlanQuery(id: planInstance.id), planInstance.toJson(), multiUpdate: false);

	Future updateMultiplePlanInstances(List<PlanInstance> planInstances) {
		return dbClient.updateAll(Collection.planInstance, planInstances.map((planInstance) => _buildPlanQuery(id: planInstance.id)).toList(),
				planInstances.map((planInstance) => planInstance.toJson()).toList(), multiUpdate: false);
	}

	Future updateActivePlanInstanceState(ObjectId childId, PlanInstanceState state) {
		var document = modify;
		if (state != null)
			document.set('state', state.index);
		return dbClient.update(Collection.planInstance, where.eq('assignedTo', childId).and(where.eq('state', PlanInstanceState.active.index)), document);
	}

	Future createPlanInstances(List<PlanInstance> plans) {
		var query = (PlanInstance plan) => where.allEq({
			'planID': plan.planID,
			'assignedTo': plan.assignedTo,
			'date': plan.date
		});
		var insert = (PlanInstance plan) => modify.setAllOnInsert(plan.toJson());
	  return dbClient.updateAll(Collection.planInstance, plans.map((plan) => query(plan)).toList(), plans.map((plan) => insert(plan)).toList());
	}

	Future updatePlan(Plan plan) => dbClient.update(Collection.plan, _buildPlanQuery(id: plan.id), plan.toJson(), multiUpdate: false);
	Future createPlan(Plan plan) => dbClient.insert(Collection.plan, plan.toJson());

	Future removePlans({List<ObjectId>? ids, ObjectId? caregiverId}) {
		var query = _buildPlanQuery(ids: ids, caregiverId: caregiverId);
		return dbClient.remove(Collection.plan, query);
	}
	Future removePlanInstances({ObjectId? planId, List<ObjectId>? ids, List<ObjectId>? childIds}) {
		var query = _buildPlanQuery(ids: ids, childIDs: childIds, planId: planId);
		return dbClient.remove(Collection.planInstance, query);
	}

	SelectorBuilder _buildPlanQuery({ObjectId? id, List<ObjectId>? ids, ObjectId? caregiverId, ObjectId? childId, ObjectId? planId,
			PlanInstanceState? state, Date? date, DateSpan<Date>? between, bool? active, List<ObjectId>? childIDs}) {
		SelectorBuilder query = where;
		if (id != null)
			query.eq('_id', id);
		if (ids != null)
			query.oneFrom('_id', ids);
		if (childId != null)
			query.eq('assignedTo', childId);
		if (childIDs != null)
			query.oneFrom('assignedTo', childIDs);
		if (caregiverId != null)
			query.eq('createdBy', caregiverId);
		if (active != null)
			query.eq('active', active);
		if (state != null)
			query.eq('state', state.index);
		if (planId != null)
			query.eq('planID', planId);

		if (date != null)
			query.eq('date', date);
		if (between?.from != null)
			query.gte('date', between!.from);
		if (between?.to != null)
			query.lt('date', between!.to);
		return query;
	}
}
