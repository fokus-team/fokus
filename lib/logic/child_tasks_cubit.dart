import 'package:flutter/cupertino.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/services/task_instance_service.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChildTasksCubit extends ReloadableCubit {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final TaskInstanceService _taskInstancesService = GetIt.I<TaskInstanceService>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();
	final ObjectId planInstanceId;
	ChildTasksCubit(this.planInstanceId, ModalRoute modalRoute) : super(modalRoute);

	@override
	void doLoadData() async {
		var getDescription = (Plan plan, [Date instanceDate]) => _repeatabilityService.buildPlanDescription(plan.repeatability, instanceDate: instanceDate);
		var planInstance = await _dataRepository.getPlanInstance(id: planInstanceId);
		var plan = await _dataRepository.getPlan(id: planInstance.planID);
		var elapsedTime = () => sumDurations(planInstance.duration).inSeconds;
		var completedTasks = await _dataRepository.getCompletedTaskCount(planInstance.id);
		var uiPlanInstance = UIPlanInstance.fromDBModel(planInstance, plan.name, completedTasks, elapsedTime, getDescription(plan, planInstance.date));
		var allTasksInstances = await _dataRepository.getTaskInstances(planInstanceId: planInstanceId);

		List<UITaskInstance> uiInstances = await _taskInstancesService.mapToUIModels(allTasksInstances);
		emit(ChildTasksLoadSuccess(uiInstances, uiPlanInstance));
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
