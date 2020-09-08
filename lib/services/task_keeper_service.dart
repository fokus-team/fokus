import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:get_it/get_it.dart';

class TaskKeeperService {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();


	Future createTaskInstances(PlanInstance planInstance) async {
		List<Task> tasks = await _dataRepository.getTasks(planId: planInstance.planID);
		var taskInstances = tasks.map((task) => TaskInstance.fromTask(task, planInstance.id)).toList();
		return Future.wait(
			[
				_dataRepository.createTaskInstances(taskInstances),
				_dataRepository.updatePlanInstances(planInstance.id, taskInstances: taskInstances.map((taskInstance) => taskInstance.id).toList())
			]
		);
	}
}
