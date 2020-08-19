import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/ui/plan/ui_plan_currency.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/utils/task_status_checker.dart';
import 'package:get_it/get_it.dart';

import '../../services/data/data_repository.dart';

Future<List<UITaskInstance>> getTaskInstanceListfromDb(List<TaskInstance> taskInstances) async {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	var taskUiTypes = getTasksInstanceStatus(tasks: taskInstances);
	List<UITaskInstance> uiTaskInstances = [];
	for(int i=0; i<taskInstances.length; i++) {
		var task = await _dataRepository.getTask(taskId: taskInstances[i].taskID);
		uiTaskInstances.add(UITaskInstance.listFromDBModel(taskInstances[i], task.name, task.description, UIPlanCurrency(id: task.points.createdBy, type: task.points.icon, title: task.points.name), task.points.quantity, taskUiTypes[i]));
	}
	return uiTaskInstances;
}
