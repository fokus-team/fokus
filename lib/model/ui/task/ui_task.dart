import 'package:bson/bson.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/ui/plan/ui_plan_currency.dart';
import 'package:fokus/model/ui/task/ui_task_base.dart';

class UITask extends UITaskBase {
	final UIPlanCurrency currency;
	final int points;
	final int timer;
	final ObjectId planId;

  UITask(ObjectId id, String name, bool optional, String description, this.currency, this.points, this.timer, this.planId) : super(id, name, optional, description);
  UITask.fromDBModel(Task task) : this(task.id, task.name, task.optional, task.description, UIPlanCurrency(id: task.points.createdBy ,type: task.points.icon, title: task.points.name), task.points.quantity, task.timer, task.planID);

	@override
	List<Object> get props => super.props..addAll([[currency, points, timer, planId]]);

	String print() {
		return 'UITask{name: $name, optional: $optional, description: $description, currency: $currency, points: $points, timer: $timer';
	}
}
