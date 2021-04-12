import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TaskInProgressParams {
	final ObjectId taskId;
	final UIPlanInstance planInstance;

  TaskInProgressParams({required this.taskId, required this.planInstance});
}
