import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../model/db/plan/plan_instance.dart';
import '../../model/db/plan/plan_instance_state.dart';
import '../../model/db/plan/task_instance.dart';
import '../../model/db/plan/task_status.dart';
import '../../model/navigation/plan_instance_params.dart';
import '../../model/notification/notification_refresh_info.dart';
import '../../model/notification/notification_type.dart';
import '../../model/ui/plan/ui_plan_instance.dart';
import '../../model/ui/plan/ui_task_instance.dart';
import '../../services/analytics_service.dart';
import '../../services/data/data_repository.dart';
import '../../services/task_instance_service.dart';
import '../../services/ui_data_aggregator.dart';
import '../../utils/duration_utils.dart';
import 'stateful/stateful_cubit.dart';


class PlanInstanceCubit extends StatefulCubit {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final TaskInstanceService _taskInstancesService = GetIt.I<TaskInstanceService>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();

	UIPlanInstance uiPlan;
	late PlanInstance _planInstance;

	PlanInstanceCubit(PlanInstanceParams params, ModalRoute modalRoute) : uiPlan = params.planInstance, super(modalRoute);

	@override
	List<NotificationType> notificationTypeSubscription() => [NotificationType.taskApproved, NotificationType.taskRejected, NotificationType.taskFinished, NotificationType.taskUnfinished];

	@override
  bool shouldNotificationRefresh(NotificationRefreshInfo info) => info.subject == uiPlan.instance.id;

  @override
	Future doLoadData() async {
		_planInstance = (await _dataRepository.getPlanInstance(id: uiPlan.instance.id))!;
		if(_planInstance.taskInstances == null || _planInstance.taskInstances!.isEmpty)
			_taskInstancesService.createTaskInstances(_planInstance);
		uiPlan = await _dataAggregator.loadPlanInstance(planInstance: _planInstance);
		var allTasksInstances = await _dataRepository.getTaskInstances(planInstanceId: uiPlan.instance.id);

		var uiInstances = await _taskInstancesService.mapToUIModels(allTasksInstances);
		emit(PlanInstanceCubitState(tasks: uiInstances, uiPlan: uiPlan));
	}

	Future<bool> isOtherPlanInProgressDbCheck({required ObjectId? tappedTaskInstance}) async {
		var activePlanInstance = await _dataRepository.getPlanInstance(childId: _planInstance.assignedTo, state: PlanInstanceState.active, fields: ["_id"]);
		if(activePlanInstance != null) {
			var taskInstances = await _dataRepository.getTaskInstances(planInstanceId: activePlanInstance.id);
			for(var instance in taskInstances) {
				if(isInProgress(instance.duration) || isInProgress(instance.breaks)) {
					if(tappedTaskInstance != null && tappedTaskInstance == instance.id) return false;
					return true;
				}
			}
		}
		return false;
	}

	Future completePlan() => submitData(body: () async {
		var updates = <Future>[];
		_planInstance.state = PlanInstanceState.completed;
		var allTasksInstances = await _dataRepository.getTaskInstances(planInstanceId: uiPlan.instance.id);
		var updatedTaskInstances = <TaskInstance>[];
		for (var taskInstance in allTasksInstances) {
			if (!taskInstance.status!.completed!) {
				taskInstance.status!.state = TaskState.rejected;
				taskInstance.status!.completed = true;
				if (isInProgress(taskInstance.duration)) {
					taskInstance.duration!.last = taskInstance.duration!.last.end();
					updates.add(_dataRepository.updateTaskInstanceFields(
						taskInstance.id!,
						state: taskInstance.status?.state,
						isCompleted: taskInstance.status?.completed,
						duration: taskInstance.duration,
					));
				}
				else if (isInProgress(taskInstance.breaks)) {
					taskInstance.breaks!.last = taskInstance.breaks!.last.end();
					updates.add(_dataRepository.updateTaskInstanceFields(
						taskInstance.id!,
						state: taskInstance.status?.state,
						isCompleted: taskInstance.status?.completed,
						breaks: taskInstance.breaks,
					));
				}
				else
					updates.add(_dataRepository.updateTaskInstanceFields(
						taskInstance.id!,
						state: taskInstance.status?.state,
						isCompleted: taskInstance.status?.completed,
					));
			}
			updatedTaskInstances.add(taskInstance);
		}
		if (isInProgress(_planInstance.duration)) {
			_planInstance.duration!.last = _planInstance.duration!.last.end();
			updates.add(_dataRepository.updatePlanInstanceFields(_planInstance.id!, state: PlanInstanceState.completed, duration: _planInstance.duration));
		}
		else
			updates.add(_dataRepository.updatePlanInstanceFields(_planInstance.id!, state: PlanInstanceState.completed));
		var uiInstances = await _taskInstancesService.mapToUIModels(updatedTaskInstances);
		_analyticsService.logPlanCompleted(_planInstance);

		Future.wait(updates);
		uiPlan = await _dataAggregator.loadPlanInstance(planInstanceId: _planInstance.id);
		emit(PlanInstanceCubitState(tasks: uiInstances, uiPlan: uiPlan, submissionState: DataSubmissionState.submissionSuccess));
	});
}

class PlanInstanceCubitState extends StatefulState {
	final List<UITaskInstance> tasks;
	final UIPlanInstance uiPlan;

	PlanInstanceCubitState({required this.tasks, required this.uiPlan, DataSubmissionState? submissionState}) : super.loaded(submissionState);

	@override
  StatefulState withSubmitState(DataSubmissionState submissionState) => PlanInstanceCubitState(tasks: tasks, uiPlan: uiPlan, submissionState: submissionState);

  @override
	List<Object?> get props => super.props..addAll([tasks, uiPlan]);
}
