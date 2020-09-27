import 'package:bson/bson.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/task/ui_task_base.dart';
import 'package:fokus/services/task_instance_service.dart';

enum TaskUIType {completed, available, inBreak, currentlyPerformed, rejected, queued, notCompletedUndefined}

extension TaskUITypeGroups on TaskUIType {
	bool get inProgress => this == TaskUIType.inBreak || this == TaskUIType.currentlyPerformed;
	bool get wasInProgress => this == TaskUIType.rejected || this == TaskUIType.completed;
	bool get canBeStarted => this == TaskUIType.available || this == TaskUIType.rejected;
}

class UITaskInstance extends UITaskBase {
	final int timer;
	final List<DateSpan<TimeDate>> duration;
	final List<DateSpan<TimeDate>> breaks;
	final ObjectId planInstanceId;
	final ObjectId taskId;
	final UIPoints points;
	final TaskUIType taskUiType;
	final TaskStatus status;
	final int Function() elapsedTimePassed;

  UITaskInstance({ObjectId id, String name, bool optional, String description, this.timer, this.duration, this.breaks, this.planInstanceId, this.points, this.taskId, this.taskUiType, this.status, this.elapsedTimePassed}) : super(id, name, optional, description);
	UITaskInstance.singleFromDBModel({TaskInstance taskInstance, String name, String description, UIPoints points, int Function() elapsedTimePassed}) : this(id: taskInstance.id, name: name, optional: taskInstance.optional, description: description, timer: taskInstance.timer, duration: taskInstance.duration, breaks: taskInstance.breaks, planInstanceId: taskInstance.planInstanceID, points: points, taskId: taskInstance.taskID, taskUiType: TaskInstanceService.getSingleTaskInstanceStatus(task: taskInstance), status: taskInstance.status, elapsedTimePassed: elapsedTimePassed = _defElapsedTime);
	UITaskInstance.singleWithTask({TaskInstance taskInstance, Task task, int Function() elapsedTimePassed}) : this(id: taskInstance.id, name: task.name, optional: taskInstance.optional, description: task.description, timer: taskInstance.timer, duration: taskInstance.duration, breaks: taskInstance.breaks, planInstanceId: taskInstance.planInstanceID, points: task.points != null ? UIPoints(quantity: task.points.quantity, title: task.points.name, createdBy: task.points.createdBy, type: task.points.icon) : null, taskId: taskInstance.taskID, taskUiType: TaskInstanceService.getSingleTaskInstanceStatus(task: taskInstance), status: taskInstance.status, elapsedTimePassed: elapsedTimePassed = _defElapsedTime);

	UITaskInstance.listFromDBModel({TaskInstance taskInstance, String name, String description, UIPoints points, TaskUIType type, int Function() elapsedTimePassed}) : this(id: taskInstance.id, name: name, optional: taskInstance.optional, description: description, timer: taskInstance.timer, duration: taskInstance.duration, breaks: taskInstance.breaks, planInstanceId: taskInstance.planInstanceID, points: points, taskId: taskInstance.taskID, taskUiType: type, status: taskInstance.status, elapsedTimePassed: elapsedTimePassed = _defElapsedTime);

	@override
	List<Object> get props => super.props..addAll([timer, duration, breaks, planInstanceId, taskId, points]);

	@override
	String toString() {
		return 'UITask{name: $name, optional: $optional, description: $description, duration: $duration, breaks: $breaks, timer: $timer';
	}

	static int _defElapsedTime() => 0;
}
