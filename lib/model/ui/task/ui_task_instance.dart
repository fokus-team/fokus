import 'package:bson/bson.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/ui/plan/ui_plan_currency.dart';
import 'package:fokus/model/ui/task/ui_task_base.dart';
import 'package:fokus/services/task_instances_service.dart';

class UITaskInstance extends UITaskBase {
	final int timer;
	final List<DateSpan<TimeDate>> duration;
	final List<DateSpan<TimeDate>> breaks;
	final ObjectId planInstanceId;
	final ObjectId taskId;
	final UIPlanCurrency currency;
	final int points;
	final TaskUIType taskUiType;
	final TaskStatus status;

  UITaskInstance(ObjectId id, String name, bool optional, String description, this.timer, this.duration, this.breaks, this.planInstanceId, this.currency, this.points, this.taskId, this.taskUiType, this.status) : super(id, name, optional, description);
	UITaskInstance.singleFromDBModel(TaskInstance task, String name, String description, UIPlanCurrency currency, int points) : this(task.id, name, task.optional, description, task.timer, task.duration, task.breaks, task.planInstanceID, currency, points, task.taskID, TaskInstancesService().getSingleTaskInstanceStatus(task: task), task.status);
	UITaskInstance.listFromDBModel(TaskInstance task, String name, String description, UIPlanCurrency currency, int points, TaskUIType type) : this(task.id, name, task.optional, description, task.timer, task.duration, task.breaks, task.planInstanceID, currency, points, task.taskID, type, task.status);


	@override
	List<Object> get props => super.props..addAll([[timer, duration, breaks, planInstanceId, taskId, currency, points]]);

	String print() {
		return 'UITask{name: $name, optional: $optional, description: $description, duration: $duration, breaks: $breaks, timer: $timer';
	}
}
