import 'package:flutter/cupertino.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/services/task_instance_service.dart';
import 'package:fokus/services/task_keeper_service.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlanInstanceCubit extends ReloadableCubit {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final TaskInstanceService _taskInstancesService = GetIt.I<TaskInstanceService>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();
	final ObjectId _planInstanceId;
	final TaskKeeperService _taskKeeperService = GetIt.I<TaskKeeperService>();
	final AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();
	PlanInstanceCubit(this._planInstanceId, ModalRoute modalRoute) : super(modalRoute);

	@override
	void doLoadData() async {
		var getDescription = (Plan plan, [Date instanceDate]) => _repeatabilityService.buildPlanDescription(plan.repeatability, instanceDate: instanceDate);
		var planInstance = await _dataRepository.getPlanInstance(id: _planInstanceId);
		if(planInstance.taskInstances == null || planInstance.taskInstances.isEmpty)
			_taskKeeperService.createTaskInstances(planInstance);
		var plan = await _dataRepository.getPlan(id: planInstance.planID);
		var elapsedTime = () => sumDurations(planInstance.duration).inSeconds;
		var completedTasks = await _dataRepository.getCompletedTaskCount(planInstance.id);
		var uiPlanInstance = UIPlanInstance.fromDBModel(planInstance, plan.name, completedTasks, elapsedTime, getDescription(plan, planInstance.date));
		var allTasksInstances = await _dataRepository.getTaskInstances(planInstanceId: _planInstanceId);
		bool isOtherPlanInProgress = planInstance.state == PlanInstanceState.active ? false : await isAnyTaskActive(childId: planInstance.assignedTo);

		List<UITaskInstance> uiInstances = await _taskInstancesService.mapToUIModels(allTasksInstances);
		emit(ChildTasksLoadSuccess(uiInstances, uiPlanInstance, isOtherPlanInProgress));
	}


	Future<bool> isAnyTaskActive({ObjectId childId}) async {
		bool isActive = _appConfigRepository.getActiveTaskState();
		if(isActive != null) return isActive;
		return _setTaskState(childId: childId);
	}

	Future<bool> _setTaskState({ObjectId childId}) async {
		List<PlanInstance> planInstances = await _dataRepository.getPlanInstances(childIDs: [childId], state: PlanInstanceState.active);
		if(planInstances != null && planInstances.isNotEmpty) {
			List<TaskInstance> taskInstances = await _dataRepository.getTaskInstances(planInstanceId: planInstances.first.id);
			for(var instance in taskInstances) {
				if(isInProgress(instance.duration) || isInProgress(instance.breaks)) {
					_appConfigRepository.setActiveTaskState(true);
					return true;
				}
			}
		}
		_appConfigRepository.setActiveTaskState(false);
		return false;
	}
}

class ChildTasksLoadSuccess extends DataLoadSuccess {
	final List<UITaskInstance> tasks;
	final UIPlanInstance planInstance;
	final bool isOtherPlanInProgress;

	ChildTasksLoadSuccess(this.tasks, this.planInstance, this.isOtherPlanInProgress);

	@override
	List<Object> get props => [tasks, planInstance, isOtherPlanInProgress];

	@override
	String toString() {
		return 'ChildTasksLoadSuccess{tasks: $tasks, planInstance: $planInstance, isOtherPlanInProgress: $isOtherPlanInProgress}';
	}
}
