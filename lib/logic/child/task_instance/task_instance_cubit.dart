import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/ui_data_aggregator.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'task_instance_state.dart';

class TaskInstanceCubit extends Cubit<TaskInstanceState> {
	final ObjectId _taskInstanceId;
	final ActiveUserFunction _activeUser;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();

	TaskInstanceCubit(this._taskInstanceId, this._activeUser, UIPlanInstance _uiPlanInstance) : super(TaskInstanceStateInitial(_uiPlanInstance));

	TaskInstance _taskInstance;
	PlanInstance _planInstance;
	Task _task;
	Plan _plan;


  void loadTaskInstance() async {
		_taskInstance = await _dataRepository.getTaskInstance(taskInstanceId: _taskInstanceId);
		_task = await _dataRepository.getTask(taskId: _taskInstance.taskID);
		_planInstance = await _dataRepository.getPlanInstance(id: _taskInstance.planInstanceID);
		_plan = await _dataRepository.getPlan(id: _planInstance.planID);

		List<Future> updates = [];
		bool wasPlanStateChanged = false, wasPlanDurationChanged = false;

		if(_planInstance.state != PlanInstanceState.active) {
			_planInstance.state = PlanInstanceState.active;
			wasPlanStateChanged = true;

			if (_planInstance.state == PlanInstanceState.notStarted)
				_analyticsService.logPlanStarted(_planInstance);
			else if (_planInstance.state == PlanInstanceState.notCompleted)
				_analyticsService.logPlanResumed(_planInstance);
			var childId = _activeUser().id;
			updates.add(_dataRepository.updateActivePlanInstanceState(childId, PlanInstanceState.notCompleted));
		}
		if(!isInProgress(_taskInstance.duration) && !isInProgress(_taskInstance.breaks)) {
			_analyticsService.logTaskStarted(_taskInstance);
			if(_taskInstance.duration == null) _taskInstance.duration = [];
			_taskInstance.duration.add(DateSpan(from: TimeDate.now()));
			updates.add(_dataRepository.updateTaskInstanceFields(_taskInstance.id, duration: _taskInstance.duration, isCompleted: _taskInstance.status.completed ? false : null));
			if(_taskInstance.status.completed) _taskInstance.status.completed = false;

			if(_planInstance.duration == null) _planInstance.duration = [];
			_planInstance.duration.add(DateSpan(from: TimeDate.now()));
			wasPlanDurationChanged = true;
		}
		if(wasPlanStateChanged || wasPlanDurationChanged)
			updates.add(_dataRepository.updatePlanInstanceFields(
					_planInstance.id,
					state: wasPlanStateChanged ? PlanInstanceState.active : null,
					duration: wasPlanDurationChanged ? _planInstance.duration : null)
			);
		await Future.value(updates);

		UITaskInstance uiTaskInstance = UITaskInstance.singleWithTask(taskInstance: _taskInstance, task: _task);
		if(isInProgress(uiTaskInstance.duration))
		  emit(TaskInstanceInProgress(uiTaskInstance,  await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan)));
		else
		  emit(TaskInstanceInBreak(uiTaskInstance,  await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan)));
	}

	void switchToBreak() async {
		_taskInstance.duration.last.to = TimeDate.now();
		_taskInstance.breaks.add(DateSpan(from: TimeDate.now()));
		await _dataRepository.updateTaskInstanceFields(_taskInstance.id, duration: _taskInstance.duration, breaks: _taskInstance.breaks);
		UITaskInstance uiTaskInstance = UITaskInstance.singleWithTask(taskInstance: _taskInstance, task: _task);
		_analyticsService.logTaskPaused(_taskInstance);
		emit(TaskInstanceInBreak(uiTaskInstance,  await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan)));
	}

	void switchToProgress() async {
		_taskInstance.breaks.last.to = TimeDate.now();
		_taskInstance.duration.add(DateSpan(from: TimeDate.now()));
		await _dataRepository.updateTaskInstanceFields(_taskInstance.id, duration: _taskInstance.duration, breaks: _taskInstance.breaks);
		UITaskInstance uiTaskInstance = UITaskInstance.singleWithTask(taskInstance: _taskInstance, task: _task);
		_analyticsService.logTaskResumed(_taskInstance);
		emit(TaskInstanceInProgress(uiTaskInstance, await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan)));
	}

	void markAsFinished() async {
  	_notificationService.sendTaskFinishedNotification(_taskInstanceId, _task.name, _plan.createdBy, _activeUser(), completed: true);
	  _analyticsService.logTaskFinished(_taskInstance);
		emit(TaskInstanceFinished(await _onCompletion(TaskState.notEvaluated), await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan)));
  }

	void markAsNotFinished() async {
		_notificationService.sendTaskFinishedNotification(_taskInstanceId, _task.name, _plan.createdBy, _activeUser(), completed: false);
		_analyticsService.logTaskNotFinished(_taskInstance);
		emit(TaskInstanceNotFinished(await _onCompletion(TaskState.rejected), await _dataAggregator.loadPlanInstance(planInstance: _planInstance, plan: _plan)));
	}

	void updateChecks(int index, MapEntry<String, bool> subtask) async {
  	_taskInstance.subtasks[index] = subtask;
		await _dataRepository.updateTaskInstanceFields(_taskInstance.id, subtasks: _taskInstance.subtasks);
		emit((state as TaskInstanceInProgress).copyWith(taskInstance: UITaskInstance.singleWithTask(taskInstance: _taskInstance, task: _task)));
	}

	Future<UITaskInstance> _onCompletion(TaskState state) async {
		_taskInstance.status.state = state;
		_taskInstance.status.completed = true;
		if(_taskInstance.duration.last.to == null) {
			_taskInstance.duration.last.to = TimeDate.now();
			await _dataRepository.updateTaskInstanceFields(_taskInstance.id, state: state, isCompleted: true, duration: _taskInstance.duration);
		}
		else {
			_taskInstance.breaks.last.to = TimeDate.now();
			await _dataRepository.updateTaskInstanceFields(_taskInstance.id, state: state, isCompleted: true, breaks: _taskInstance.breaks);
		}

		if(await _dataRepository.getCompletedTaskCount(_planInstance.id) == _planInstance.taskInstances.length) {
			_planInstance.state = PlanInstanceState.completed;
			_analyticsService.logPlanCompleted(_planInstance);
		}
		_planInstance.duration.last.to = TimeDate.now();
		await _dataRepository.updatePlanInstanceFields(_planInstance.id, duration: _planInstance.duration, state: _planInstance.state == PlanInstanceState.completed ? PlanInstanceState.completed : null);

		return UITaskInstance.singleWithTask(taskInstance: _taskInstance, task: _task);
	}
}
