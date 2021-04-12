import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';

class TaskFormParams {
	final TaskFormModel task;
	final List<UICurrency> currencies;
	final Function? createTaskCallback;
	final Function? removeTaskCallback;
	final Function? saveTaskCallback;

  TaskFormParams({required this.task, required this.currencies, this.createTaskCallback, this.removeTaskCallback, this.saveTaskCallback});
}
