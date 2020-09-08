import 'package:bson/bson.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/task/ui_task_base.dart';
import 'package:fokus/services/task_instance_service.dart';

enum TaskUIType {completed, available, inBreak, currentlyPerformed, rejected, queued, notCompletedUndefined}

extension TaskUITypeGroups on TaskUIType {
	bool get inProgress => this == TaskUIType.inBreak || this == TaskUIType.currentlyPerformed;
	bool get wasInProgress => this == TaskUIType.rejected || this == TaskUIType.completed;
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
	UITaskInstance.singleFromDBModel({TaskInstance task, String name, String description, UIPoints points, int Function() elapsedTimePassed}) : this(id: task.id, name: name, optional: task.optional, description: description, timer: task.timer, duration: task.duration, breaks: task.breaks, planInstanceId: task.planInstanceID, points: points, taskId: task.taskID, taskUiType: TaskInstanceService.getSingleTaskInstanceStatus(task: task), status: task.status, elapsedTimePassed: elapsedTimePassed = _defElapsedTime);
	UITaskInstance.listFromDBModel({TaskInstance task, String name, String description, UIPoints points, TaskUIType type, int Function() elapsedTimePassed}) : this(id: task.id, name: name, optional: task.optional, description: description, timer: task.timer, duration: task.duration, breaks: task.breaks, planInstanceId: task.planInstanceID, points: points, taskId: task.taskID, taskUiType: type, status: task.status, elapsedTimePassed: elapsedTimePassed = _defElapsedTime);


	@override
	List<Object> get props => super.props..addAll([timer, duration, breaks, planInstanceId, taskId, points]);

	@override
	String toString() {
		return 'UITask{name: $name, optional: $optional, description: $description, duration: $duration, breaks: $breaks, timer: $timer';
	}

	static int _defElapsedTime() => 0;
}
