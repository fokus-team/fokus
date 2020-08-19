import 'package:flutter/cupertino.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/task_instance.dart';

enum TaskUIType {completed, available, inProgress, queued, notCompletedUndefined}

enum TaskInProgressType {inProgress, inBreak, notInProgress}

List<TaskUIType> getTasksInstanceStatus({@required List<TaskInstance> tasks}) {
	List<TaskUIType> taskStatuses = [];
	TaskUIType prevTaskStatus;
	for(var task in tasks) {
		var taskStatus;
		if(task.status.completed) taskStatus = TaskUIType.completed;
		else if(task.optional || prevTaskStatus == null || prevTaskStatus == TaskUIType.completed)
			if(checkInProgressType(task.duration, task.breaks) != TaskInProgressType.notInProgress) taskStatus = TaskUIType.inProgress;
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
	if(duration.length > 0 && duration.last.to == null) return TaskInProgressType.inProgress;
	else if(breaks.length > 0 && breaks.last.to == null) return TaskInProgressType.inBreak;
	else return TaskInProgressType.notInProgress;
}

