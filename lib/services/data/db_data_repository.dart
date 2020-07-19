import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/services/remote_config_provider.dart';
import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/data/mongodb_provider.dart';

import 'data_repository.dart';

class DbDataRepository implements DataRepository {
	final MongoDbProvider client = MongoDbProvider();

	@override
	Future initialize() async => client.initialize(GetIt.I<RemoteConfigProvider>().dbAccessString);

	@override
	Future<User> getUser([SelectorBuilder selector]) {
		return client.queryOne(Collection.user, selector).then((response) => User.typedFromJson(response));
	}

	@override
	Future<Map<ObjectId, String>> getUserNames(List<ObjectId> users) {
		var query = where.oneFrom('_id', users).fields(['name', '_id']);
		return client.queryTypedMap(Collection.user, query, (json) => MapEntry(json['_id'], json['name']));
	}

	@override
	Future<List<Child>> getCaregiverChildren(ObjectId caregiverId) {
		var query = where.eq('role', UserRole.child.index).and(where.eq('connections', caregiverId));
		return client.queryTyped(Collection.user, query, (json) => Child.fromJson(json));
	}

	// Temporary until we have a login page
	@override
	Future<User> getUserById(ObjectId id) => getUser(where.eq('_id', id));
	@override
	Future<User> getUserByRole(UserRole role) => getUser(where.eq('role', role.index));

	@override
	Future<List<Plan>> getChildPlans(ObjectId childId, {bool activeOnly = true}) {
		var query = _buildPlanQuery(childId, activeOnly: activeOnly);
		return client.queryTyped(Collection.plan, query, (json) => Plan.fromJson(json));
	}

	@override
	Future<List<Plan>> getChildPlanInstances(ObjectId childId, {ObjectId planId, Date date, bool activeOnly = false}) {
		var query = _buildPlanQuery(childId, planId: planId, date: date, activeOnly: activeOnly);
		return client.queryTyped(Collection.planInstance, query, (json) => Plan.fromJson(json));
	}

	@override
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
