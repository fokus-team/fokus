import 'package:bson/bson.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/utils/app_locales.dart';

import 'ui_plan_base.dart';

class UIPlanInstance extends UIPlanBase {
	final int taskCount;
	final int completedTaskCount;
	final int timeRemaining;
	final PlanInstanceState state;

	UIPlanInstance(ObjectId id, String name, this.taskCount, this.completedTaskCount, this.timeRemaining, this.state, [TranslateFunc description]) : super(id, name, description);
  UIPlanInstance.fromDBModel(PlanInstance plan, String planName, this.completedTaskCount, this.timeRemaining, [TranslateFunc description]) :
			  taskCount = plan.tasks.length, state = plan.state, super(plan.id, planName, description);

	@override
  List<Object> get props => super.props..addAll([taskCount]);
}
