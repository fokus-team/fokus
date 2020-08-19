import 'package:flutter/material.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/ui/plan/ui_plan_currency.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:get_it/get_it.dart';

import 'data/data_repository.dart';

enum TaskUIType {completed, available, inProgress, stopped, queued, notCompletedUndefined}

enum TaskInProgressType {inProgress, inBreak, stopped, notInProgress}

class TaskInstancesService {
	Future<List<UITaskInstance>> getTaskInstanceListfromDb(List<TaskInstance> taskInstances) async {
		final DataRepository _dataRepository = GetIt.I<DataRepository>();
		var taskUiTypes = getTasksInstanceStatus(tasks: taskInstances);
		List<UITaskInstance> uiTaskInstances = [];
		for(int i=0; i<taskInstances.length; i++) {
			var task = await _dataRepository.getTask(taskId: taskInstances[i].taskID);
			uiTaskInstances.add(UITaskInstance.listFromDBModel(taskInstances[i], task.name, task.description, UIPlanCurrency(id: task.points.createdBy, type: task.points.icon, title: task.points.name), task.points.quantity, taskUiTypes[i]));
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
			else if((task.optional&&!isAnyInProgress) || prevTaskStatus == null || prevTaskStatus == TaskUIType.completed)
				if(checkInProgressType(task.duration, task.breaks) == TaskInProgressType.stopped) taskStatus = TaskUIType.stopped;
				else if(checkInProgressType(task.duration, task.breaks) != TaskInProgressType.notInProgress) {
					taskStatus = TaskUIType.inProgress;
					isAnyInProgress = true;
				}
				else taskStatus = TaskUIType.available;
			else taskStatus = TaskUIType.queued;
			taskStatuses.add(taskStatus);
			prevTaskStatus = taskStatus;
		}
		return taskStatuses;
	}

	TaskUIType getSingleTaskInstanceStatus({@required TaskInstance task}) {
		if(task.status.completed) return TaskUIType.completed;
		else return TaskUIType.notCompletedUndefined;
	}

	TaskInProgressType checkInProgressType(List<DateSpan<TimeDate>> duration, List<DateSpan<TimeDate>> breaks,) {
		if(breaks.length > 0 && breaks.last.to == null) return TaskInProgressType.inBreak;
		else if(duration.length > 0)
			if(duration.last.to == null) return TaskInProgressType.inProgress;
			else return TaskInProgressType.stopped;
		else return TaskInProgressType.notInProgress;
	}
}
