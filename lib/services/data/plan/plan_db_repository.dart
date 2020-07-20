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

	Future<bool> childActivePlanInstanceExists(ObjectId childId) => client.exists(Collection.planInstance, _buildPlanQuery(childId, activeOnly: true));

	SelectorBuilder _buildPlanQuery(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false}) {
		var query = where.eq('assignedTo', childId);
		if (activeOnly)
			query.and(where.eq('active', true));
		if (planId != null)
			query.and(where.eq('planID', planId));
		if (date != null)
			query.and(where.eq('date', date));
		return query;
	}
}
