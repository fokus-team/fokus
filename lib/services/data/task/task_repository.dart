import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:mongo_dart/mongo_dart.dart';


abstract class TaskRepository {
	Future<int> getCompletedTaskCount(ObjectId planInstanceId);
	Future<List<Task>> getTasks({ObjectId planId, List<ObjectId> ids, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future<List<TaskInstance>> getTaskInstances({ObjectId planInstanceId, List<ObjectId> taskInstancesIds, List<ObjectId> planInstancesId, bool requiredOnly = false, bool optionalOnly = false, bool isCompleted, TaskState state, List<String> fields});
	Future<Task> getTask({ObjectId taskId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future<TaskInstance> getTaskInstance({ObjectId taskInstanceId, bool requiredOnly = false, bool optionalOnly = false, List<String> fields});
	Future createTasks(List<Task> tasks);
	Future updateTasks(List<Task> tasks);
	Future createTaskInstances(List<TaskInstance> taskInstances);
	Future updateTaskInstance(TaskInstance taskInstance);
	Future updateTaskInstanceFields(ObjectId taskInstanceId, {TaskState state, List<DateSpan<TimeDate>> duration, List<DateSpan<TimeDate>> breaks, bool isCompleted, int rating, int pointsAwarded});

}
