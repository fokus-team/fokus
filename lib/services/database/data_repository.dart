import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/database/mongo_client.dart';

class DataRepository {
	final MongoClient client = MongoClient();

	Future<DataRepository> initialize(String config) async {
		await client.initialize(config);
		return this;
	}

	Future<User> getUser([SelectorBuilder selector]) {
		return client.queryOne(Collection.user, selector).then((response) => User.typedFromJson(response));
	}

	Future<List<Child>> getCaregiverChildren(ObjectId caregiverId) {
		var query = where.eq('role', UserRole.child.index).and(where.eq('connections', caregiverId));
		return _executeQuery(Collection.user, query, (json) => Child.fromJson(json));
	}

	Future<List<Plan>> getChildPlans(ObjectId childId, {bool activeOnly = true}) {
		var query = _buildPlanQuery(childId, activeOnly: activeOnly);
		return _executeQuery(Collection.plan, query, (json) => Plan.fromJson(json));
	}

	Future<List<Plan>> getChildPlanInstances(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false}) {
		var query = _buildPlanQuery(childId, planId: planId, date: date, activeOnly: activeOnly);
		return _executeQuery(Collection.planInstance, query, (json) => Plan.fromJson(json));
	}

	Future<bool> childActivePlanInstanceExists(ObjectId childId) => client.exists(Collection.planInstance, _buildPlanQuery(childId, activeOnly: true));

	// Temporary until we have a login page
	Future<User> getUserById(ObjectId id) => getUser(where.eq('_id', id));
	Future<User> getUserByRole(UserRole role) => getUser(where.eq('role', role.index));

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

	Future<List<T>> _executeQuery<T>(Collection collection, SelectorBuilder query, T Function(Map<String, dynamic>) constructElement) {
		return client.query(collection, query).then((response) => response.map((element) => constructElement(element)).toList());
	}
}
