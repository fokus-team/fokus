import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/task_status.dart';
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

	Future<List<TaskInstance>> getTaskInstancesFromIds({List<ObjectId> taskInstancesIds, bool requiredOnly = false, bool optionalOnly = false, List<String> fields}) {
		var query = _buildTaskQuery(ids: taskInstancesIds, optionalOnly: optionalOnly, requiredOnly: requiredOnly);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.taskInstance, query, (json) => TaskInstance.fromJson(json));
	}


	Future<Task> getTask({ObjectId taskId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields}) {
		var query = _buildTaskQuery(id: taskId, optionalOnly: optionalOnly, requiredOnly: requiredOnly);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.task, query, (json) => Task.fromJson(json));
	}

	Future<TaskInstance> getTaskInstance({ObjectId taskInstanceId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields}) {
		var query = _buildTaskQuery(id: taskInstanceId, optionalOnly: optionalOnly, requiredOnly: requiredOnly);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.taskInstance, query, (json) => TaskInstance.fromJson(json));
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

	Future createTaskInstances(List<TaskInstance> taskInstances) {
		return dbClient.insertMany(Collection.taskInstance, taskInstances.map((taskInstance) => taskInstance.toJson()).toList());
	}

	Future createTasks(List<Task> tasks) => dbClient.insertMany(Collection.task, tasks.map((task) => task.toJson()).toList());
	
	Future updateTasks(List<Task> tasks) {
		return dbClient.updateAll(Collection.task, tasks.map((task) => _buildTaskQuery(id: task.id)).toList(), tasks.map((task) => task.toJson()).toList(), multiUpdate: false);
	}


	Future updateTaskInstance(TaskInstance taskInstance) => dbClient.update(Collection.taskInstance, _buildTaskQuery(id: taskInstance.id), taskInstance.toJson(), multiUpdate: false);

	Future updateTaskInstanceFields(ObjectId taskInstanceId, {TaskState state, List<DateSpan<TimeDate>> duration, List<DateSpan<TimeDate>> breaks, bool isCompleted, int rating, int pointsAwarded}) {
		var document = modify;
		if (state != null)
			document.set('status.state', state.index);
		if (duration != null)
			document.set('duration', duration.map((v) => v.toJson()).toList());
		if (breaks != null)
			document.set('breaks', breaks.map((v) => v.toJson()).toList());
		if (isCompleted != null)
			document.set('status.completed', isCompleted);
		if (rating != null)
			document.set('status.rating', rating);
		if (pointsAwarded != null)
			document.set('status.pointsAwarded', pointsAwarded);
		return dbClient.update(Collection.taskInstance, where.eq('_id', taskInstanceId), document);
	}

	SelectorBuilder _buildTaskQuery({ObjectId id, List<ObjectId> ids, ObjectId planId, ObjectId planInstanceId, bool requiredOnly, bool optionalOnly}) {
		SelectorBuilder query = where;
		if (planId != null && planInstanceId != null)
			_logger.warning("Both plan and plan instance IDs specified in task query");
		if ((requiredOnly ?? false) && (optionalOnly ?? false))
			_logger.warning("Both required and optional only flags specified in task query");

		if (id != null)
			query.eq('_id', id);
		if (ids != null)
			query.oneFrom('_id', ids);
		if (planId != null)
			query.eq('planID', planId);
		if (planInstanceId != null)
			query.eq('planInstanceID', planInstanceId);
		if (requiredOnly ?? false)
			query.notExists('optional').or(where.eq('optional', false));
		if (optionalOnly ?? false)
			query.eq('optional', true);
		if (query.map.isEmpty)
			return null;
		return query;
	}
}
