import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin PlanDbRepository implements DbRepository {
	Future<List<Plan>> getChildPlans(ObjectId childId, {bool activeOnly = true}) {
		var query = _buildPlanQuery(Collection.plan, childId, activeOnly: activeOnly);
		return client.queryTyped(Collection.plan, query, (json) => Plan.fromJson(json));
	}

	Future<List<Plan>> getChildPlanInstances(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false}) {
		var query = _buildPlanQuery(Collection.planInstance, childId, planId: planId, date: date, activeOnly: activeOnly);
		return client.queryTyped(Collection.planInstance, query, (json) => Plan.fromJson(json));
	}

	Future<PlanInstance> getActiveChildPlanInstance(ObjectId childId) {
	  return client.queryOneTyped(Collection.planInstance, _buildPlanQuery(Collection.planInstance, childId, activeOnly: true), (json) => PlanInstance.fromJson(json));
	}

	SelectorBuilder _buildPlanQuery(Collection collection, ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false}) {
		var query = where.eq('assignedTo', childId);
		if (activeOnly)
			collection == Collection.plan ? query.and(where.eq('active', true)) : query.and(where.eq('state', PlanInstanceState.active.index));
		if (planId != null)
			query.and(where.eq('planID', planId));
		if (date != null)
			query.and(where.eq('date', date));
		return query;
	}
}
