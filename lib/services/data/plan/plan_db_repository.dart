import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin PlanDbRepository implements DbRepository {
	Future<List<Plan>> getChildPlans(ObjectId childId, {bool activeOnly = true}) {
		var query = _buildPlanQuery(childId, activeOnly: activeOnly);
		return client.queryTyped(Collection.plan, query, (json) => Plan.fromJson(json));
	}

	Future<List<Plan>> getChildPlanInstances(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false}) {
		var query = _buildPlanQuery(childId, planId: planId, date: date, activeOnly: activeOnly);
		return client.queryTyped(Collection.planInstance, query, (json) => Plan.fromJson(json));
	}

	Future<PlanInstance> getActiveChildPlanInstance(ObjectId childId) {
	  return client.queryOneTyped(Collection.planInstance, _buildPlanQuery(childId, state: PlanInstanceState.active), (json) => PlanInstance.fromJson(json));
	}

	Future<List<PlanInstance>> getPlanInstancesForPlans(ObjectId childId, List<ObjectId> planIDs) {
		var query = _buildPlanQuery(childId).and(where.oneFrom('planID', planIDs));
		return client.queryTyped(Collection.planInstance, query, (json) => PlanInstance.fromJson(json));
	}

	SelectorBuilder _buildPlanQuery(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false, PlanInstanceState state}) {
		var query = where.eq('assignedTo', childId);
		if (activeOnly)
			query.and(where.eq('active', true));
		if (state != null)
			query.and(where.eq('state', state.index));
		if (planId != null)
			query.and(where.eq('planID', planId));
		if (date != null)
			query.and(where.eq('date', date));
		return query;
	}
}
