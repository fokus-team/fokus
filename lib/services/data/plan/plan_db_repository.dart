import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/services/data/db/db_repository.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';

mixin PlanDbRepository implements DbRepository {
	Future<List<Plan>> getCaregiverPlans(ObjectId caregiverId, {bool activeOnly = true}) {
		var query = _buildPlanQuery(caregiverId: caregiverId, activeOnly: activeOnly);
		return dbClient.queryTyped(Collection.plan, query, (json) => Plan.fromJson(json));
	}

	Future<List<Plan>> getChildPlans(ObjectId childId, {bool activeOnly = true}) {
		var query = _buildPlanQuery(childId: childId, activeOnly: activeOnly);
		return dbClient.queryTyped(Collection.plan, query, (json) => Plan.fromJson(json));
	}

	Future<List<Plan>> getChildPlanInstances(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false}) {
		var query = _buildPlanQuery(childId: childId, planId: planId, date: date, activeOnly: activeOnly);
		return dbClient.queryTyped(Collection.planInstance, query, (json) => Plan.fromJson(json));
	}

	Future<PlanInstance> getActiveChildPlanInstance(ObjectId childId) {
		return dbClient.queryOneTyped(Collection.planInstance, _buildPlanQuery(childId: childId, state: PlanInstanceState.active), (json) => PlanInstance.fromJson(json));
	}

	Future<List<PlanInstance>> getPlanInstancesForPlans(ObjectId childId, List<ObjectId> planIDs, [Date date]) {
		var query = _buildPlanQuery(childId: childId, date: date).and(where.oneFrom('planID', planIDs));
		return dbClient.queryTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json));
	}

	Future<List<PlanInstance>> getPastNotCompletedPlanInstances(ObjectId childId, List<ObjectId> planIDs, Date beforeDate) {
		var query = _buildPlanQuery(childId: childId).and(where.oneFrom('planID', planIDs)).and(where.lt('date', beforeDate)).and(where.ne('state', PlanInstanceState.completed.index));
		return dbClient.queryTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json));
	}

	SelectorBuilder _buildPlanQuery({ObjectId caregiverId, ObjectId childId, ObjectId planId, Date date, bool activeOnly = false, PlanInstanceState state}) {
		SelectorBuilder query;
		var addExpression = (expression) => query == null ? (query = expression) : query.and(expression);
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
		return query;
	}
}
