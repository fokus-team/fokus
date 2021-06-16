import '../db/gamification/currency.dart';
import '../ui/form/task_form_model.dart';

class TaskFormParams {
	final TaskFormModel? task;
	final List<Currency> currencies;
	final Future<void> Function(TaskFormModel)? createTaskCallback;
	final Future<void> Function()? removeTaskCallback;
	final Future<void> Function(TaskFormModel)? saveTaskCallback;

  TaskFormParams({required this.task, required this.currencies, this.createTaskCallback, this.removeTaskCallback, this.saveTaskCallback});
}
