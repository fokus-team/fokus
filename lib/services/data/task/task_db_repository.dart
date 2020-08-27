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

	Future<Task> getTask({ObjectId taskId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields}) {
		var query = _buildTaskQuery(id: taskId, optionalOnly: optionalOnly, requiredOnly: requiredOnly);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.task, query, (json) => Task.fromJson(json));
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

	Future createTasks(List<Task> tasks) => dbClient.insertMany(Collection.task, tasks.map((task) => task.toJson()).toList());
	
	Future updateTasks(List<Task> tasks) {
		return dbClient.updateAll(Collection.task, tasks.map((task) => _buildTaskQuery(id: task.id)).toList(), tasks.map((task) => task.toJson()).toList(), multiUpdate: false);
	}

	SelectorBuilder _buildTaskQuery({ObjectId id, ObjectId planId, ObjectId planInstanceId, bool requiredOnly, bool optionalOnly}) {
		SelectorBuilder query = where;
		if (planId != null && planInstanceId != null)
			_logger.warning("Both plan and plan instance IDs specified in task query");
		if ((requiredOnly ?? false) && (optionalOnly ?? false))
			_logger.warning("Both required and optional only flags specified in task query");

		if (id != null)
			query.eq('_id', id);
		if (planId != null)
			query.eq('planID', planId);
		if (planInstanceId != null)
			query.eq('planInstanceID', planInstanceId);
		if (requiredOnly ?? false)
			query.notExists('optional').or(where.eq('optional', false));
		if (optionalOnly ?? false)
			query.eq('optional', true);
		return query;
	}
}
