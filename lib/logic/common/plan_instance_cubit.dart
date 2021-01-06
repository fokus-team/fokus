import 'package:flutter/cupertino.dart';
import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/ui_data_aggregator.dart';
import 'package:fokus/services/task_instance_service.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/db/date/time_date.dart';


class PlanInstanceCubit extends ReloadableCubit {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final TaskInstanceService _taskInstancesService = GetIt.I<TaskInstanceService>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();
	UIPlanInstance uiPlanInstance;

	PlanInstance planInstance;

	PlanInstanceCubit(this.uiPlanInstance, ModalRoute modalRoute) : super(modalRoute);

	@override
	List<NotificationType> dataTypeSubscription() => [NotificationType.taskApproved, NotificationType.taskRejected, NotificationType.taskFinished, NotificationType.taskUnfinished];

	@override
	void doLoadData() async {
		planInstance = await _dataRepository.getPlanInstance(id: uiPlanInstance.id);
		if(planInstance.taskInstances == null || planInstance.taskInstances.isEmpty)
			_taskInstancesService.createTaskInstances(planInstance);
		uiPlanInstance = await _dataAggregator.loadPlanInstance(planInstance: planInstance);
		var allTasksInstances = await _dataRepository.getTaskInstances(planInstanceId: uiPlanInstance.id);

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

	void completePlan() async {
		List<Future> updates = [];
		planInstance.state = PlanInstanceState.completed;
		var allTasksInstances = await _dataRepository.getTaskInstances(planInstanceId: uiPlanInstance.id);
		List<TaskInstance> updatedTaskInstances = [];
		for(var taskInstance in allTasksInstances) {
			if(!taskInstance.status.completed) {
				taskInstance.status.state = TaskState.rejected;
				taskInstance.status.completed = true;
				if(isInProgress(taskInstance.duration)) {
					taskInstance.duration.last.to = TimeDate.now();
					updates.add(_dataRepository.updateTaskInstanceFields(taskInstance.id, state: taskInstance.status.state, isCompleted: taskInstance.status.completed, duration: taskInstance.duration));
				}
				else if(isInProgress(taskInstance.breaks)) {
					taskInstance.breaks.last.to = TimeDate.now();
					updates.add(_dataRepository.updateTaskInstanceFields(taskInstance.id, state: taskInstance.status.state, isCompleted: taskInstance.status.completed, breaks: taskInstance.breaks));
				}
				else updates.add(_dataRepository.updateTaskInstanceFields(taskInstance.id, state: taskInstance.status.state, isCompleted: taskInstance.status.completed));
			}
			updatedTaskInstances.add(taskInstance);
		}
		if(isInProgress(planInstance.duration)) {
			planInstance.duration.last.to =  TimeDate.now();
			updates.add(_dataRepository.updatePlanInstanceFields(planInstance.id, state: PlanInstanceState.completed, duration: planInstance.duration));
		}
		else updates.add(_dataRepository.updatePlanInstanceFields(planInstance.id, state: PlanInstanceState.completed));
		List<UITaskInstance> uiInstances = await _taskInstancesService.mapToUIModels(updatedTaskInstances);

		Future.wait(updates);
		uiPlanInstance = await _dataAggregator.loadPlanInstance(planInstance: planInstance);
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
