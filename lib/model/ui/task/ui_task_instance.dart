import 'package:bson/bson.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/ui/task/ui_task_base.dart';

class UITaskInstance extends UITaskBase {
	final ObjectId taskInstanceId;
	final int timer;
	final List<DateSpan<TimeDate>> duration;
	final List<DateSpan<TimeDate>> breaks;
	final ObjectId planInstanceId;

  UITaskInstance(ObjectId id, bool optional, this.taskInstanceId, this.timer, this.duration, this.breaks, this.planInstanceId) : super(id, optional);
	UITaskInstance.fromDBModel(TaskInstance task) : this(task.id, task.optional, task.id, task.timer, task.duration, task.breaks, task.planInstanceID);

	@override
	List<Object> get props => super.props..addAll([[taskInstanceId, timer, duration, breaks, planInstanceId]]);

	String print() {
		return 'UITask{optional: $optional, duration: $duration, breaks: $breaks, timer: $timer';
	}
}
