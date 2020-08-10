import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/services/data/db/db_repository.dart';
import 'package:fokus/model/db/plan/task_instance.dart';

mixin TaskDbRepository implements DbRepository {
	final Logger _logger = Logger('TaskDbRepository');

	Future<List<Task>> getTasks({ObjectId planId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields}) {
		var query = _buildTaskQuery(planId: planId, optionalOnly: optionalOnly, requiredOnly: requiredOnly);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.task, query, (json) => Task.fromJson(json));
	}

	Future<List<TaskInstance>> getTaskInstances({ObjectId planInstanceId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields}) {
		var query = _buildTaskQuery(planInstanceId: planInstanceId, requiredOnly: requiredOnly, optionalOnly: optionalOnly);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.taskInstance, query, (json) => TaskInstance.fromJson(json));
	}

	Future<int> getCompletedTaskCount(ObjectId planInstanceId) {
		return dbClient.count(Collection.taskInstance, where.eq('planInstanceID', planInstanceId).and(where.eq('status.completed', true)));
	}

	SelectorBuilder _buildTaskQuery({ObjectId planId, ObjectId planInstanceId, bool requiredOnly, bool optionalOnly}) {
		SelectorBuilder query;
		var addExpression = (expression) => query == null ? (query = expression) : query.and(expression);
		if (planId != null && planInstanceId != null)
			_logger.warning("Both plan and plan instance IDs specified in task query");
		if (requiredOnly && optionalOnly)
			_logger.warning("Both required and optional only flags specified in task query");

		if (planId != null)
			addExpression(where.eq('planID', planId));
		if (planInstanceId != null)
			addExpression(where.eq('planInstanceID', planInstanceId));
		if (requiredOnly)
			addExpression(where.notExists('optional').or(where.eq('optional', false)));
		if (optionalOnly)
			addExpression(where.eq('optional', true));
		return query;
	}
}
