import 'package:flutter/material.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';

import 'data/data_repository.dart';

class TaskInstanceService {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	Future<List<UITaskInstance>> mapToUIModels(List<TaskInstance> taskInstances) async {
		var taskUiTypes = getTasksInstanceStatus(tasks: taskInstances);
		List<UITaskInstance> uiTaskInstances = [];
		for(int i=0; i<taskInstances.length; i++) {
			var task = await _dataRepository.getTask(taskId: taskInstances[i].taskID);
			int Function() elapsedTimePassed;
			if(taskUiTypes[i].inProgress)
				elapsedTimePassed = () => taskUiTypes[i] == TaskUIType.currentlyPerformed ? sumDurations(taskInstances[i].duration).inSeconds : sumDurations(taskInstances[i].breaks).inSeconds;
			else elapsedTimePassed = () => 0;
			uiTaskInstances.add(UITaskInstance.listFromDBModel(taskInstance: taskInstances[i], name: task.name, description: task.description, points: task.points != null ? UIPoints(quantity: task.points.quantity, type: task.points.icon, title: task.points.name) : null, type: taskUiTypes[i], elapsedTimePassed: elapsedTimePassed));
		}
		return uiTaskInstances;
	}

	List<TaskUIType> getTasksInstanceStatus({@required List<TaskInstance> tasks}) {
		List<TaskUIType> taskStatuses = [];
		TaskUIType prevTaskStatus;
		bool isAnyInProgress = false;
		for(var task in tasks) {
			var taskStatus;
			if(task.status.completed) {
				task.status.state == TaskState.rejected ? taskStatus = TaskUIType.rejected
					: taskStatus = TaskUIType.completed;
			}
			else if((task.optional && !isAnyInProgress) || prevTaskStatus == null || prevTaskStatus.wasInProgress) {
				taskStatus = _getInProgressType(task);
				if(taskStatus != TaskUIType.rejected && taskStatus != TaskUIType.available)
					isAnyInProgress = true;
			}
			else taskStatus = TaskUIType.queued;
			taskStatuses.add(taskStatus);
			prevTaskStatus = taskStatus;
		}
		while(isAnyInProgress && taskStatuses.contains(TaskUIType.available)) taskStatuses[taskStatuses.indexOf(TaskUIType.available)] = TaskUIType.queued;
		return taskStatuses;
	}

	static TaskUIType getSingleTaskInstanceStatus({@required TaskInstance task}) {
		if(task.status.completed) return TaskUIType.completed;
		else return _getInProgressType(task);
	}


	static TaskUIType _getInProgressType(TaskInstance task) {
		TaskUIType taskStatus;
		if(task.breaks.length > 0 && task.breaks.last.to == null)
			taskStatus = TaskUIType.inBreak;
		else if(task.duration.length > 0)
			task.duration.last.to == null ? taskStatus = TaskUIType.currentlyPerformed
				: taskStatus = TaskUIType.rejected;
		else
			taskStatus = TaskUIType.available;
		return taskStatus;
	}

	Future createTaskInstances(PlanInstance planInstance) async {
		List<Task> tasks = await _dataRepository.getTasks(planId: planInstance.planID);
		var taskInstances = tasks.map((task) => TaskInstance.fromTask(task, planInstance.id)).toList();
		return Future.wait(
			[
				_dataRepository.createTaskInstances(taskInstances),
				_dataRepository.updatePlanInstanceFields(planInstance.id, taskInstances: taskInstances.map((taskInstance) => taskInstance.id).toList())
			]
		);
	}
}
