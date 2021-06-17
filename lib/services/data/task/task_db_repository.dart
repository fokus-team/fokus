import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../model/db/collection.dart';
import '../../../model/db/date/time_date.dart';
import '../../../model/db/date_span.dart';
import '../../../model/db/plan/task.dart';
import '../../../model/db/plan/task_instance.dart';
import '../../../model/db/plan/task_status.dart';
import '../db/db_repository.dart';

mixin TaskDbRepository implements DbRepository {
	final Logger _logger = Logger('TaskDbRepository');

	Future<List<Task>> getTasks({ObjectId? planId, List<ObjectId>? ids, bool requiredOnly = false, bool optionalOnly = false, List<String>? fields}) {
		var query = _buildTaskQuery(planId: planId, ids: ids, optionalOnly: optionalOnly, requiredOnly: requiredOnly);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.task, query, (json) => Task.fromJson(json));
	}

	Future<Task?> getTask({ObjectId? taskId, bool requiredOnly = false, bool optionalOnly = false, List<String>? fields}) {
		var query = _buildTaskQuery(id: taskId, optionalOnly: optionalOnly, requiredOnly: requiredOnly);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.task, query, (json) => json != null ? Task.fromJson(json) : null);
	}

	Future<TaskInstance?> getTaskInstance({ObjectId? taskInstanceId, bool requiredOnly = false, bool optionalOnly = false, List<String>? fields}) {
		var query = _buildTaskQuery(id: taskInstanceId, optionalOnly: optionalOnly, requiredOnly: requiredOnly);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryOneTyped(Collection.taskInstance, query, (json) => json != null ? TaskInstance.fromJson(json) : null);
	}

	Future<List<TaskInstance>> getTaskInstances({ObjectId? planInstanceId, List<ObjectId>? taskInstancesIds, List<ObjectId>? planInstancesId,
		bool requiredOnly = false, bool optionalOnly = false, bool? isCompleted, TaskState? state, List<String>? fields}) {
		var query = _buildTaskQuery(planInstanceId: planInstanceId, ids: taskInstancesIds, requiredOnly: requiredOnly,
				optionalOnly: optionalOnly, isCompleted: isCompleted, planInstancesIds: planInstancesId, state: state);
		if (fields != null)
			query.fields(fields);
		return dbClient.queryTyped(Collection.taskInstance, query, (json) => TaskInstance.fromJson(json));
	}

	Future<int> countTaskInstances({List<ObjectId>? planInstancesId, bool? isCompleted, TaskState? state}) {
		var query = _buildTaskQuery(isCompleted: isCompleted, planInstancesIds: planInstancesId, state: state);
		return dbClient.count(Collection.taskInstance, query);
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

	Future updateTaskInstanceFields(ObjectId taskInstanceId, {TaskState? state, List<DateSpan<TimeDate>>? duration, List<DateSpan<TimeDate>>? breaks,
		bool? isCompleted, int? rating, int? pointsAwarded, List<MapEntry<String, bool>>? subtasks, String? ratingComment}) {
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
		if (ratingComment != null)
			document.set('status.comment', ratingComment);
		if(subtasks != null)
			document.set('subtasks', subtasks.map((v) => {v.key: v.value}).toList());
		return dbClient.update(Collection.taskInstance, where.eq('_id', taskInstanceId), document);
	}

	Future removeTasks({required List<ObjectId> planIds}) {
		var query = _buildTaskQuery(planIds: planIds);
		return dbClient.remove(Collection.task, query);
	}
	Future removeTaskInstances({List<ObjectId>? tasksIds, List<ObjectId>? planInstancesIds}) {
		var query = _buildTaskQuery(tasksIds: tasksIds, planInstancesIds: planInstancesIds);
		return dbClient.remove(Collection.taskInstance, query);
	}

	SelectorBuilder _buildTaskQuery({ObjectId? id, List<ObjectId>? ids, List<ObjectId>? planIds, List<ObjectId>? tasksIds, ObjectId? planId, ObjectId? planInstanceId, List<ObjectId>? planInstancesIds, bool? requiredOnly, bool? optionalOnly, bool? isCompleted, TaskState? state}) {
		var query = where;
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
		if (planIds != null)
			query.oneFrom('planID', planIds);
		if (tasksIds != null)
			query.oneFrom('taskID', tasksIds);
		if (planInstanceId != null)
			query.eq('planInstanceID', planInstanceId);
		if (planInstancesIds != null)
			query.oneFrom('planInstanceID', planInstancesIds);
		if (requiredOnly ?? false)
			query.notExists('optional').or(where.eq('optional', false));
		if (optionalOnly ?? false)
			query.eq('optional', true);
		if (state != null)
			query.eq('status.state', state.index);
		if (isCompleted != null)
			query.eq('status.completed', isCompleted);
		return query;
	}
}
