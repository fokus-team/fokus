import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TaskRepository {
	Future<List<Task>> getTasks({ObjectId planId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future<List<TaskInstance>> getTaskInstances({ObjectId planInstanceId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future<int> getCompletedTaskCount(ObjectId planInstanceId);
	Future<Task> getTask({ObjectId taskId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future createTasks(List<Task> tasks);
	Future updateTasks(List<Task> tasks);
}
