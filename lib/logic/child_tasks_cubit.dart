import 'package:flutter/cupertino.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/task_instance_service.dart';
import 'package:get_it/get_it.dart';



class ChildTasksCubit extends ReloadableCubit {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final TaskInstanceService _taskInstancesService = GetIt.I<TaskInstanceService>();
	final UIPlanInstance _uiPlanInstance;
	ChildTasksCubit(this._uiPlanInstance, ModalRoute modalRoute) : super(modalRoute);


	@override
	void doLoadData() async {
		var planInstanceId = _uiPlanInstance.id;
		var allTasksInstances = await _dataRepository.getTaskInstances(planInstanceId: planInstanceId);
		List<UITaskInstance> uiInstances = await _taskInstancesService.mapToUIModels(allTasksInstances);
		emit(ChildTasksLoadSuccess(uiInstances, _uiPlanInstance));
	}
}

class ChildTasksLoadSuccess extends DataLoadSuccess {
	final List<UITaskInstance> tasks;
	final UIPlanInstance planInstance;

	ChildTasksLoadSuccess(this.tasks, this.planInstance);

	@override
	List<Object> get props => [tasks, planInstance];

	@override
	String toString() {
		return 'ChildTasksLoadSuccess{tasks: $tasks, planInstance: $planInstance}';
	}
}
