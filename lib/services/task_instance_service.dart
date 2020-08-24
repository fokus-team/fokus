import 'package:flutter/material.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';

import 'data/data_repository.dart';

enum TaskUIType {completed, available, inBreak, stopped, currentlyPerformed, queued, notCompletedUndefined}

extension TaskUITypeGroups on TaskUIType {
	bool get inProgress => this == TaskUIType.inBreak || this == TaskUIType.stopped || this == TaskUIType.currentlyPerformed;
}

class TaskInstanceService {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	Future<List<UITaskInstance>> mapToUIModels(List<TaskInstance> taskInstances) async {
		var taskUiTypes = getTasksInstanceStatus(tasks: taskInstances);
		List<UITaskInstance> uiTaskInstances = [];
		for(int i=0; i<taskInstances.length; i++) {
			var task = await _dataRepository.getTask(taskId: taskInstances[i].taskID);
			if(taskUiTypes[i] == TaskUIType.currentlyPerformed || taskUiTypes[i] == TaskUIType.inBreak) {
				var elapsedTimePassed = () =>  taskUiTypes[i] == TaskUIType.currentlyPerformed ? sumDurations(taskInstances[i].duration).inSeconds : sumDurations(taskInstances[i].breaks).inSeconds;
				uiTaskInstances.add(UITaskInstance.listFromDBModel(taskInstances[i], task.name, task.description, UIPoints(quantity: task.points.quantity, type: task.points.icon, title: task.points.name), taskUiTypes[i], elapsedTimePassed: elapsedTimePassed));
			}
			else uiTaskInstances.add(UITaskInstance.listFromDBModel(taskInstances[i], task.name, task.description, UIPoints(quantity: task.points.quantity, type: task.points.icon, title: task.points.name), taskUiTypes[i]));
		}
		return uiTaskInstances;
	}

	List<TaskUIType> getTasksInstanceStatus({@required List<TaskInstance> tasks}) {
		List<TaskUIType> taskStatuses = [];
		TaskUIType prevTaskStatus;
		bool isAnyInProgress = false;
		for(var task in tasks) {
			var taskStatus;
			if(task.status.completed) taskStatus = TaskUIType.completed;
			else if((task.optional&&!isAnyInProgress) || prevTaskStatus == null || prevTaskStatus == TaskUIType.completed) {
				if(task.breaks.length > 0 && task.breaks.last.to == null) taskStatus = TaskUIType.inBreak;
				else if(task.duration.length > 0)
					if(task.duration.last.to == null) taskStatus = TaskUIType.currentlyPerformed;
					else taskStatus = TaskUIType.stopped;
				else taskStatus = TaskUIType.available;
				if(taskStatus != TaskUIType.stopped) isAnyInProgress = true;
			}
			else taskStatus = TaskUIType.queued;
			taskStatuses.add(taskStatus);
			prevTaskStatus = taskStatus;
		}
		return taskStatuses;
	}

	static TaskUIType getSingleTaskInstanceStatus({@required TaskInstance task}) {
		if(task.status.completed) return TaskUIType.completed;
		else return TaskUIType.notCompletedUndefined;
	}
}
