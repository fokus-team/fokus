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

	TaskInstanceCubit(this._taskInstanceId, this._activeUser) : super(TaskInstanceStateInitial());

	TaskInstance taskInstance;
	PlanInstance planInstance;
	Task task;
	Plan plan;


  void loadTaskInstance() async {
		taskInstance = await _dataRepository.getTaskInstance(taskInstanceId: _taskInstanceId);
		task = await _dataRepository.getTask(taskId: taskInstance.taskID);
		planInstance = await _dataRepository.getPlanInstance(id: taskInstance.planInstanceID);
		plan = await _dataRepository.getPlan(id: planInstance.planID);

		List<Future> updates = [];
		bool wasPlanStateChanged = false, wasPlanDurationChanged = false;

		if(planInstance.state != PlanInstanceState.active) {
			planInstance.state = PlanInstanceState.active;
			wasPlanStateChanged = true;

			var childId = _activeUser().id;
			updates.add(_dataRepository.updateActivePlanInstanceState(childId, PlanInstanceState.notCompleted));
		}
		if(!isInProgress(taskInstance.duration) && !isInProgress(taskInstance.breaks)) {
			if(taskInstance.duration == null) taskInstance.duration = [];
			taskInstance.duration.add(DateSpan(from: TimeDate.now()));
			updates.add(_dataRepository.updateTaskInstanceFields(taskInstance.id, duration: taskInstance.duration, isCompleted: taskInstance.status.completed ? false : null));
			if(taskInstance.status.completed) taskInstance.status.completed = false;

			if(planInstance.duration == null) planInstance.duration = [];
			planInstance.duration.add(DateSpan(from: TimeDate.now()));
			wasPlanDurationChanged = true;
		}
		if(wasPlanStateChanged || wasPlanDurationChanged) updates.add(_dataRepository.updatePlanInstanceFields(planInstance.id, state:wasPlanStateChanged ? PlanInstanceState.active : null, duration: wasPlanDurationChanged ? planInstance.duration : null));
		await Future.value(updates);

		UITaskInstance uiTaskInstance = UITaskInstance.singleWithTask(taskInstance: taskInstance, task: task);
		if(isInProgress(uiTaskInstance.duration)) emit(TaskInstanceStateProgress(uiTaskInstance,  await _dataAggregator.loadPlanInstance(planInstance: planInstance, plan: plan)));
		else  emit(TaskInstanceStateBreak(uiTaskInstance,  await _dataAggregator.loadPlanInstance(planInstance: planInstance, plan: plan)));
	}

	void switchToBreak() async {
		taskInstance.duration.last.to = TimeDate.now();
		taskInstance.breaks.add(DateSpan(from: TimeDate.now()));
		await _dataRepository.updateTaskInstanceFields(taskInstance.id, duration: taskInstance.duration, breaks: taskInstance.breaks);
		UITaskInstance uiTaskInstance = UITaskInstance.singleWithTask(taskInstance: taskInstance, task: task);
		emit(TaskInstanceStateBreak(uiTaskInstance,  await _dataAggregator.loadPlanInstance(planInstance: planInstance, plan: plan)));
	}

	void switchToProgress() async {
		taskInstance.breaks.last.to = TimeDate.now();
		taskInstance.duration.add(DateSpan(from: TimeDate.now()));
		await _dataRepository.updateTaskInstanceFields(taskInstance.id, duration: taskInstance.duration, breaks: taskInstance.breaks);
		UITaskInstance uiTaskInstance = UITaskInstance.singleWithTask(taskInstance: taskInstance, task: task);
		emit(TaskInstanceStateProgress(uiTaskInstance, await _dataAggregator.loadPlanInstance(planInstance: planInstance, plan: plan)));
	}

	void markAsDone() async {
  	_notificationService.sendTaskFinishedNotification(_taskInstanceId, task.name, plan.createdBy, _activeUser(), completed: true);
		emit(TaskInstanceStateDone(await _onCompletion(TaskState.notEvaluated), await _dataAggregator.loadPlanInstance(planInstance: planInstance, plan: plan)));
  }

	void markAsRejected() async {
		_notificationService.sendTaskFinishedNotification(_taskInstanceId, task.name, plan.createdBy, _activeUser(), completed: false);
		emit(TaskInstanceStateRejected(await _onCompletion(TaskState.rejected), await _dataAggregator.loadPlanInstance(planInstance: planInstance, plan: plan)));
	}

	Future<UITaskInstance> _onCompletion(TaskState state) async {
		taskInstance.status.state = state;
		taskInstance.status.completed = true;
		if(taskInstance.duration.last.to == null) {
			taskInstance.duration.last.to = TimeDate.now();
			await _dataRepository.updateTaskInstanceFields(taskInstance.id, state: state, isCompleted: true, duration: taskInstance.duration);
		}
		else {
			taskInstance.breaks.last.to = TimeDate.now();
			await _dataRepository.updateTaskInstanceFields(taskInstance.id, state: state, isCompleted: true, breaks: taskInstance.breaks);
		}

		if(await _dataRepository.getCompletedTaskCount(planInstance.id) == planInstance.taskInstances.length) {
			planInstance.state = PlanInstanceState.completed;
		}
		planInstance.duration.last.to = TimeDate.now();
		await _dataRepository.updatePlanInstanceFields(planInstance.id, duration: planInstance.duration, state: planInstance.state == PlanInstanceState.completed ? PlanInstanceState.completed : null);

		return UITaskInstance.singleWithTask(taskInstance: taskInstance, task: task);
	}
}
