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
	Future<Plan> getPlan({ObjectId id, List<String> fields}) {
		var query = _buildPlanQuery(id: id);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.plan, query, (json) => Plan.fromJson(json));
	}

	Future<List<Plan>> getPlans({ObjectId caregiverId, ObjectId childId, bool activeOnly = true, bool oneDayOnly = false, List<String> fields}) {
		var query = _buildPlanQuery(caregiverId: caregiverId, childId: childId, activeOnly: activeOnly);
		if (oneDayOnly)
			query.and(where.ne('repeatability.untilCompleted', true));
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.plan, query, (json) => Plan.fromJson(json));
	}

	Future<List<PlanInstance>> getPlanInstances({ObjectId childId, PlanInstanceState state, List<ObjectId> planIDs, Date date, DateSpan<Date> between}) {
		var query = _buildPlanQuery(childId: childId, state: state, date: date);
		return dbClient.queryTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json));
	}

	Future<bool> getActiveChildPlanInstance(ObjectId childId) {
		return dbClient.exists(Collection.planInstance, _buildPlanQuery(childId: childId, state: PlanInstanceState.active));
	}

	Future<List<PlanInstance>> getPlanInstancesForPlans(ObjectId childId, List<ObjectId> planIDs, [Date date]) {
		var query = _buildPlanQuery(childId: childId, date: date).and(where.oneFrom('planID', planIDs));
		return dbClient.queryTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json));
	}

	Future<List<PlanInstance>> getPastNotCompletedPlanInstances(List<ObjectId> childIDs, List<ObjectId> planIDs, Date beforeDate, {List<String> fields}) {
		var query = where.oneFrom('assignedTo', childIDs).and(where.oneFrom('planID', planIDs)).and(where.lt('date', beforeDate));
		query.and(where.ne('state', PlanInstanceState.completed.index)).and(where.ne('state', PlanInstanceState.lostForever.index));
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json));
	}
	
	Future updatePlanInstances(ObjectId instanceId, {PlanInstanceState state, DateSpanUpdate<TimeDate> durationChange}) {
		var document = modify;
		if (state != null)
			document.set('state', state.index);
		if (durationChange != null)
			document.set('duration.${durationChange.getQuery()}', durationChange.value.toDBDate());
		return dbClient.update(Collection.planInstance, where.eq('_id', instanceId), document);
	}

	Future updatePlan(Plan plan) => dbClient.replace(Collection.plan, _buildPlanQuery(id: plan.id), plan.toJson());
	Future createPlan(Plan plan) => dbClient.insert(Collection.plan, plan.toJson());

	SelectorBuilder _buildPlanQuery({ObjectId id, ObjectId caregiverId, ObjectId childId, ObjectId planId,
			PlanInstanceState state, Date date, DateSpan<Date> between, bool activeOnly = false}) {
		SelectorBuilder query;
		var addExpression = (expression) => query == null ? (query = expression) : query.and(expression);
		if (id != null)
			addExpression(where.eq('_id', id));
		if (childId != null)
			addExpression(where.eq('assignedTo', childId));
		if (caregiverId != null)
			addExpression(where.eq('createdBy', caregiverId));
		if (activeOnly)
			addExpression(where.eq('active', true));
		if (state != null)
			addExpression(where.eq('state', state.index));
		if (planId != null)
			addExpression(where.eq('planID', planId));

		if (date != null)
			addExpression(where.eq('date', date));
		if (between?.from != null)
			addExpression(where.gte('date', between.from));
		if (between?.to != null)
			addExpression(where.lt('date', between.to));
		return query;
	}
}
