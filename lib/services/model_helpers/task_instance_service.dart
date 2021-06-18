import 'package:get_it/get_it.dart';

import '../../model/db/plan/plan_instance.dart';
import '../../model/db/plan/task_instance.dart';
import '../../model/db/plan/task_status.dart';
import '../../model/ui/plan/ui_task_instance.dart';
import '../data/data_repository.dart';

class TaskInstanceService {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	Future<List<UITaskInstance>> mapToUIModels(List<TaskInstance> taskInstances, {bool shouldGetTaskStatus = true}) async {
		var taskUiTypes = shouldGetTaskStatus ? getTasksInstanceStatus(tasks: taskInstances) : List.filled(taskInstances.length, TaskInstanceState.notCompletedUndefined);
		var uiTaskInstances = <UITaskInstance>[];
		for(var i=0; i<taskInstances.length; i++) {
			var task = await _dataRepository.getTask(taskId: taskInstances[i].taskID);
			uiTaskInstances.add(UITaskInstance(instance: taskInstances[i], task: task!, state: taskUiTypes[i]));
		}
		return uiTaskInstances;
	}

	List<TaskInstanceState> getTasksInstanceStatus({required List<TaskInstance> tasks}) {
		var taskStatuses = <TaskInstanceState>[];
		TaskInstanceState? prevTaskStatus;
		var isAnyInProgress = false;
		for(var task in tasks) {
			var taskStatus;
			if(task.status != null && task.status!.completed!) {
				task.status!.state == TaskState.rejected ? taskStatus = TaskInstanceState.rejected
					: taskStatus = TaskInstanceState.completed;
			}
			else if((task.optional! && !isAnyInProgress) || prevTaskStatus == null || prevTaskStatus.wasInProgress) {
				taskStatus = _getInProgressType(task);
				if(taskStatus != TaskInstanceState.rejected && taskStatus != TaskInstanceState.available)
					isAnyInProgress = true;
			}
			else taskStatus = TaskInstanceState.queued;
			taskStatuses.add(taskStatus);
			prevTaskStatus = taskStatus;
		}
		while(isAnyInProgress && taskStatuses.contains(TaskInstanceState.available)) taskStatuses[taskStatuses.indexOf(TaskInstanceState.available)] = TaskInstanceState.queued;
		return taskStatuses;
	}

	static TaskInstanceState getSingleTaskInstanceStatus({required TaskInstance task}) {
		if(task.status != null && task.status!.completed!) return TaskInstanceState.completed;
		else return _getInProgressType(task);
	}


	static TaskInstanceState _getInProgressType(TaskInstance task) {
		TaskInstanceState taskStatus;
		if(task.breaks!.isNotEmpty && task.breaks!.last.to == null)
			taskStatus = TaskInstanceState.inBreak;
		else if(task.duration!.isNotEmpty)
			task.duration!.last.to == null ? taskStatus = TaskInstanceState.currentlyPerformed
				: taskStatus = TaskInstanceState.rejected;
		else
			taskStatus = TaskInstanceState.available;
		return taskStatus;
	}

	Future createTaskInstances(PlanInstance planInstance) async {
		var tasks = await _dataRepository.getTasks(planId: planInstance.planID);
		var taskInstances = tasks.map((task) => TaskInstance.fromTask(task, planInstance.id!)).toList();
		return Future.wait(
			[
				_dataRepository.createTaskInstances(taskInstances),
				_dataRepository.updatePlanInstanceFields(planInstance.id!, taskInstances: taskInstances.map((taskInstance) => taskInstance.id!).toList())
			]
		);
	}
}
