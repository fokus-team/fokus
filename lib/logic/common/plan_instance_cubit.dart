import 'package:flutter/cupertino.dart';
import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/ui_data_aggregator.dart';
import 'package:fokus/services/task_instance_service.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlanInstanceCubit extends ReloadableCubit {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final TaskInstanceService _taskInstancesService = GetIt.I<TaskInstanceService>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();
	final ObjectId _planInstanceId;

	PlanInstanceCubit(this._planInstanceId, ModalRoute modalRoute) : super(modalRoute);

	PlanInstance planInstance;

	@override
	void doLoadData() async {
		planInstance = await _dataRepository.getPlanInstance(id: _planInstanceId);
		if(planInstance.taskInstances == null || planInstance.taskInstances.isEmpty)
			_taskInstancesService.createTaskInstances(planInstance);
		var uiPlanInstance = await _dataAggregator.loadPlanInstance(planInstance: planInstance);
		var allTasksInstances = await _dataRepository.getTaskInstances(planInstanceId: _planInstanceId);

		List<UITaskInstance> uiInstances = await _taskInstancesService.mapToUIModels(allTasksInstances);
		emit(ChildTasksLoadSuccess(uiInstances, uiPlanInstance));
	}


	Future<bool> isOtherPlanInProgressDbCheck({ObjectId tappedTaskInstance}) async {
		PlanInstance activePlanInstance = await _dataRepository.getPlanInstance(childId: planInstance.assignedTo, state: PlanInstanceState.active, fields: ["_id"]);
		if(activePlanInstance != null) {
			List<TaskInstance> taskInstances = await _dataRepository.getTaskInstances(planInstanceId: activePlanInstance.id);
			for(var instance in taskInstances) {
				if(isInProgress(instance.duration) || isInProgress(instance.breaks)) {
					if(tappedTaskInstance != null && tappedTaskInstance == instance.id) return false;
					return true;
				}
			}
		}
		return false;
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
