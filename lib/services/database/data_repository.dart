import 'package:flutter/material.dart';
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
		return client.queryTyped(Collection.user, query, (json) => Child.fromJson(json));
	}

	Future<List<Plan>> getChildPlans(ObjectId childId, {bool activeOnly = true}) {
		var query = _buildPlanQuery(childId, activeOnly: activeOnly);
		return client.queryTyped(Collection.plan, query, (json) => Plan.fromJson(json));
	}

	Future<Map<ObjectId, String>> getUserNames(List<ObjectId> users) {
		var query = where.oneFrom('_id', users).fields(['name', '_id']);
		return client.queryTypedMap(Collection.user, query, (json) => MapEntry(json['_id'], json['name']));
	}

	Future<List<Plan>> getChildPlanInstances(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false}) {
		var query = _buildPlanQuery(childId, planId: planId, date: date, activeOnly: activeOnly);
		return client.queryTyped(Collection.planInstance, query, (json) => Plan.fromJson(json));
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
}
