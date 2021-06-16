import 'package:mongo_dart/mongo_dart.dart';

import '../ui/plan/ui_plan_instance.dart';

class TaskInProgressParams {
	final ObjectId taskId;
	final UIPlanInstance planInstance;

  TaskInProgressParams({required this.taskId, required this.planInstance});
}
