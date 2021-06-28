import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' hide Action;
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:reloadable_bloc/reloadable_bloc.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../../../model/db/date/time_date.dart';
import '../../../model/db/date_span.dart';
import '../../../model/db/plan/plan.dart';
import '../../../model/db/plan/plan_instance.dart';
import '../../../model/db/plan/plan_instance_state.dart';
import '../../../model/db/plan/task.dart';
import '../../../model/db/plan/task_instance.dart';
import '../../../model/db/plan/task_status.dart';
import '../../../model/navigation/task_in_progress_params.dart';
import '../../../model/ui/plan/ui_plan_instance.dart';
import '../../../model/ui/plan/ui_task_instance.dart';
import '../../../services/analytics_service.dart';
import '../../../services/data/data_repository.dart';
import '../../../services/model_helpers/ui_data_aggregator.dart';
import '../../../services/notifications/notification_service.dart';
import '../../../utils/duration_utils.dart';
import '../../common/cubit_base.dart';

part 'task_completion_state.dart';

class TaskCompletionCubit extends CubitBase<TaskCompletionData> {
	final ObjectId _taskInstanceId;
	final TaskInProgressParams params;

	late TaskInstance _taskInstance;
	late PlanInstance _planInstance;
	late Task _task;
	late Plan _plan;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();

	TaskCompletionCubit(this.params, ModalRoute pageRoute) : _taskInstanceId = params.taskId, super(pageRoute);

	@override
	Future reload(ReloadableReason reason) => load(
		initialData: TaskCompletionData(uiPlan: params.planInstance),
		body: () async {
			_taskInstance = (await _dataRepository.getTaskInstance(taskInstanceId: _taskInstanceId))!;
			_task = (await _dataRepository.getTask(taskId: _taskInstance.taskID))!;
			_planInstance = (await _dataRepository.getPlanInstance(id: _taskInstance.planInstanceID))!;
			_plan = (await _dataRepository.getPlan(id: _planInstance.planID!))!;

			var updates = <Future>[];
			var wasPlanStateChanged = false, wasPlanDurationChanged = false;
			var uiTaskInstance = UITaskInstance(instance: _taskInstance, task: _task);
			var planInstance = await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan);

			if (reason != ReloadableReason.push && _taskInstance.status!.completed! && (_taskInstance.status!.state == TaskState.evaluated || _taskInstance.status!.state == TaskState.rejected)) {
				if(_taskInstance.status!.state == TaskState.evaluated)
					return Action.finish(TaskCompletionData.finished(uiTask: uiTaskInstance,  uiPlan: planInstance));
				else
					return Action.finish(TaskCompletionData.discarded(uiTask: uiTaskInstance,  uiPlan: planInstance));
			}
			else {
				if(_planInstance.state != PlanInstanceState.active) {
					if (_planInstance.state == PlanInstanceState.notStarted)
						_analyticsService.logPlanStarted(_planInstance);
					else if (_planInstance.state == PlanInstanceState.notCompleted)
						_analyticsService.logPlanResumed(_planInstance);

					_planInstance.state = PlanInstanceState.active;
					wasPlanStateChanged = true;

					var childId = activeUser!.id!;
					if (await _dataRepository.hasActiveChildPlanInstance(childId))
						updates.add(_dataRepository.updateActivePlanInstanceState(childId, PlanInstanceState.notCompleted));
				}
				if(!isInProgress(_taskInstance.duration) && !isInProgress(_taskInstance.breaks)) {
					_analyticsService.logTaskStarted(_taskInstance);
					_taskInstance.duration!.add(DateSpan(from: TimeDate.now()));
					updates.add(_dataRepository.updateTaskInstanceFields(_taskInstance.id!, duration: _taskInstance.duration, isCompleted: _taskInstance.status!.completed! ? false : null));
					if(_taskInstance.status!.completed!) _taskInstance.status!.completed = false;

					if(_planInstance.duration == null) _planInstance.duration = [];
					_planInstance.duration!.add(DateSpan(from: TimeDate.now()));
					wasPlanDurationChanged = true;
				}
				if(wasPlanStateChanged || wasPlanDurationChanged)
					updates.add(_dataRepository.updatePlanInstanceFields(
							_planInstance.id!,
							state: wasPlanStateChanged ? PlanInstanceState.active : null,
							duration: wasPlanDurationChanged ? _planInstance.duration : null)
					);
				await Future.wait(updates);

				if(isInProgress(uiTaskInstance.instance.duration))
				  return Action.finish(TaskCompletionData.inProgress(uiTask: uiTaskInstance,  uiPlan: planInstance));
				else
					return Action.finish(TaskCompletionData.inBreak(uiTask: uiTaskInstance,  uiPlan: planInstance));
			}
		},
	);

	Future switchToBreak() => submit(
	  initialData: data?.copyWith(current: TaskCompletionStateType.inBreak),
		body: () async {
			_taskInstance.duration!.last = _taskInstance.duration!.last.end();
			_taskInstance.breaks!.add(DateSpan(from: TimeDate.now()));
			await _dataRepository.updateTaskInstanceFields(_taskInstance.id!, duration: _taskInstance.duration, breaks: _taskInstance.breaks);
			var uiTaskInstance = UITaskInstance(instance: _taskInstance, task: _task);
			_analyticsService.logTaskPaused(_taskInstance);
			var planInstance = await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan);
			return Action.finish(data!.copyWith(taskInstance: uiTaskInstance, planInstance: planInstance));
		},
	);

	Future switchToProgress() => submit(
	  initialData: data?.copyWith(current: TaskCompletionStateType.inProgress),
		body: () async {
			_taskInstance.breaks!.last = _taskInstance.breaks!.last.end();
			_taskInstance.duration!.add(DateSpan(from: TimeDate.now()));
			await _dataRepository.updateTaskInstanceFields(_taskInstance.id!, duration: _taskInstance.duration, breaks: _taskInstance.breaks);
			var uiTaskInstance = UITaskInstance(instance: _taskInstance, task: _task);
			_analyticsService.logTaskResumed(_taskInstance);
			var planInstance = await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan);
			return Action.finish(data!.copyWith(taskInstance: uiTaskInstance, planInstance: planInstance));
		},
	);

	Future markAsFinished() => submit(
	  initialData: data?.copyWith(current: TaskCompletionStateType.finished),
		body: () async {
	    _notificationService.sendTaskFinishedNotification(_planInstance.id!, _task.name!, _plan.createdBy!, activeUser!, completed: true);
		  _analyticsService.logTaskFinished(_taskInstance);
		  var updatedTask =  await _onCompletion(TaskState.notEvaluated);
			var planInstance = await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan);
	    return Action.finish(data!.copyWith(taskInstance: updatedTask, planInstance: planInstance));
		},
	);

	Future markAsDiscarded() => submit(
	  initialData: data?.copyWith(current: TaskCompletionStateType.discarded),
		body: () async {
			_notificationService.sendTaskFinishedNotification(_planInstance.id!, _task.name!, _plan.createdBy!, activeUser!, completed: false);
			_analyticsService.logTaskNotFinished(_taskInstance);
			var updatedTask =  await _onCompletion(TaskState.rejected);
			var planInstance = await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan);
			return Action.finish(data!.copyWith(taskInstance: updatedTask, planInstance: planInstance));
		},
	);

	void updateChecks(int index, MapEntry<String, bool> subtask) => submit(body: () async {
  	_taskInstance.subtasks![index] = subtask;
		await _dataRepository.updateTaskInstanceFields(_taskInstance.id!, subtasks: _taskInstance.subtasks);
		return Action.finish(data!.copyWith(taskInstance: UITaskInstance(instance: _taskInstance, task: _task)));
	});

	Future<UITaskInstance> _onCompletion(TaskState state) async {
		_taskInstance.status!.state = state;
		_taskInstance.status!.completed = true;
		if(_taskInstance.duration!.last.to == null) {
			_taskInstance.duration!.last = _taskInstance.duration!.last.end();
			await _dataRepository.updateTaskInstanceFields(_taskInstance.id!, state: state, isCompleted: true, duration: _taskInstance.duration);
		}
		else {
			_taskInstance.breaks!.last = _taskInstance.breaks!.last.end();
			await _dataRepository.updateTaskInstanceFields(_taskInstance.id!, state: state, isCompleted: true, breaks: _taskInstance.breaks);
		}

		if(await _dataRepository.getCompletedTaskCount(_planInstance.id!) == _planInstance.taskInstances!.length) {
			_planInstance.state = PlanInstanceState.completed;
			_analyticsService.logPlanCompleted(_planInstance);
		}
		_planInstance.duration!.last = _planInstance.duration!.last.end();
		await _dataRepository.updatePlanInstanceFields(
			_planInstance.id!,
			duration: _planInstance.duration,
			state: _planInstance.state == PlanInstanceState.completed ? PlanInstanceState.completed : null
		);

		return UITaskInstance(instance: _taskInstance, task: _task);
	}
}
