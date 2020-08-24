import 'package:bson/bson.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/task/ui_task_base.dart';


class UITask extends UITaskBase {
	final UIPoints points;
	final int timer;
	final ObjectId planId;

  UITask({ObjectId id, String name, bool optional, String description, this.points, this.timer, this.planId}) : super(id, name, optional, description);
  UITask.fromDBModel({Task task}) : this(id: task.id, name: task.name, optional: task.optional, description: task.description, points: UIPoints(quantity: task.points.quantity, type: task.points.icon, title: task.points.name),  timer: task.timer, planId: task.planID);

	@override
	List<Object> get props => super.props..addAll([points, timer, planId]);

	@override
	String toString() {
		return 'UITask{name: $name, optional: $optional, description: $description, currency: $points, points: $points, timer: $timer';
	}
}
