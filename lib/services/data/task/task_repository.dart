import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TaskRepository {
	Future<int> getCompletedTaskCount(ObjectId planInstanceId);
	Future<List<Task>> getTasks({ObjectId planId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future<List<TaskInstance>> getTaskInstances({ObjectId planInstanceId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future<Task> getTask({ObjectId taskId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future<TaskInstance> getTaskInstance({ObjectId taskInstanceId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future createTasks(List<Task> tasks);
	Future updateTasks(List<Task> tasks);
	Future createTaskInstances(List<TaskInstance> taskInstances);
	Future updateTaskInstances(List<TaskInstance> taskInstances);
	Future updateTaskInstance(TaskInstance taskInstance);


}
