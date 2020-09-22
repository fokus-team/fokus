import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/active_task_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'task_instance_state.dart';

class TaskInstanceCubit extends Cubit<TaskInstanceState> {
	final ObjectId _taskInstanceId;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final ActiveUserFunction _activeUser;

	TaskInstanceCubit(this._taskInstanceId, this._activeUser) : super(TaskInstanceStateInitial());
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();
	final ActiveTaskService _activeTaskService = GetIt.I<ActiveTaskService>();



  void loadTaskInstance() async {
		TaskInstance taskInstance = await _dataRepository.getTaskInstance(taskInstanceId: _taskInstanceId);
		PlanInstance planInstance = await _dataRepository.getPlanInstance(id: taskInstance.planInstanceID);

		List<Future> updates = [];
		List<PlanInstance> toUpdate = [];
		bool wasPlanInstanceChanged = false;

		if(planInstance.state != PlanInstanceState.active) {
			planInstance.state = PlanInstanceState.active;
			wasPlanInstanceChanged = true;

			var childId = _activeUser().id;
			var allPlans = await _dataRepository.getPlans(childId: childId);
			var todayPlans = await _repeatabilityService.filterPlansByDate(allPlans, Date.now());
			var todayPlanIds = todayPlans.map((plan) => plan.id).toList();
			var untilCompletedPlans = allPlans.where((plan) => plan.repeatability.untilCompleted && !todayPlans.contains(plan.id)).map((plan) => plan.id).toList();
			var instances = await _dataRepository.getPlanInstancesForPlans(childId, todayPlanIds, Date.now());
			instances.addAll(await _dataRepository.getPastNotCompletedPlanInstances([childId], untilCompletedPlans, Date.now()));

			for(var instance in instances) {
				if(instance.state == PlanInstanceState.active) {
					instance.state = PlanInstanceState.notCompleted;
					toUpdate.add(instance);
					break;
				}
			}
		}

		if((taskInstance.duration.length == 0 || (taskInstance.duration.length > 0 && taskInstance.duration.last.to != null)) && (taskInstance.breaks.length == 0 || (taskInstance.duration.length > 0 && taskInstance.breaks.last.to != null))) {
			if(taskInstance.duration == null) taskInstance.duration = [];
			if(taskInstance.status.completed) taskInstance.status.completed = false;
			taskInstance.duration.add(DateSpan(from: TimeDate.now()));
			updates.add(_dataRepository.updateTaskInstance(taskInstance));

			if(planInstance.duration == null) planInstance.duration = [];
			planInstance.duration.add(DateSpan(from: TimeDate.now()));
			wasPlanInstanceChanged = true;
		}
		if(wasPlanInstanceChanged) toUpdate.add(planInstance);
		updates.add(_dataRepository.updateMultiplePlanInstances(toUpdate));
		await Future.value(updates);

		Task task = await _dataRepository.getTask(taskId: taskInstance.taskID);
		UITaskInstance uiTaskInstance = UITaskInstance.singleFromDBModel(task: taskInstance, name: task.name, description: task.description, points: task.points != null ? UIPoints(quantity: task.points.quantity, title: task.points.name, createdBy: task.points.createdBy, type: task.points.icon) : null);
		_activeTaskService.setTaskStateActive();
		if(isInProgress(uiTaskInstance.duration)) emit(TaskInstanceStateProgress(uiTaskInstance,  await _getUiPlanInstance(taskInstance.planInstanceID)));
		else  emit(TaskInstanceStateBreak(uiTaskInstance,  await _getUiPlanInstance(taskInstance.planInstanceID)));
	}

	void switchToBreak() async {
		TaskInstance taskInstance = await _dataRepository.getTaskInstance(taskInstanceId: _taskInstanceId);
		taskInstance.duration.last.to = TimeDate.now();
		taskInstance.breaks.add(DateSpan(from: TimeDate.now()));
		await _dataRepository.updateTaskInstance(taskInstance);
		Task task = await _dataRepository.getTask(taskId: taskInstance.taskID);
		UITaskInstance uiTaskInstance = UITaskInstance.singleFromDBModel(task: taskInstance, name: task.name, description: task.description, points: task.points != null ? UIPoints(quantity: task.points.quantity, title: task.points.name, createdBy: task.points.createdBy, type: task.points.icon) : null);
		emit(TaskInstanceStateBreak(uiTaskInstance,  await _getUiPlanInstance(taskInstance.planInstanceID)));
	}

	void switchToProgress() async {
		TaskInstance taskInstance = await _dataRepository.getTaskInstance(taskInstanceId: _taskInstanceId);
		taskInstance.breaks.last.to = TimeDate.now();
		taskInstance.duration.add(DateSpan(from: TimeDate.now()));
		await _dataRepository.updateTaskInstance(taskInstance);
		Task task = await _dataRepository.getTask(taskId: taskInstance.taskID);
		UITaskInstance uiTaskInstance = UITaskInstance.singleFromDBModel(task: taskInstance, name: task.name, description: task.description, points: task.points != null ? UIPoints(quantity: task.points.quantity, title: task.points.name, createdBy: task.points.createdBy, type: task.points.icon) : null);
		emit(TaskInstanceStateProgress(uiTaskInstance, await _getUiPlanInstance(taskInstance.planInstanceID)));
	}

	void markAsDone() async {
		TaskInstance taskInstance = await _dataRepository.getTaskInstance(taskInstanceId: _taskInstanceId);
		PlanInstance planInstance = await _dataRepository.getPlanInstance(id: taskInstance.planInstanceID);
		planInstance.duration.last.to = TimeDate.now();

		if(taskInstance.duration.last.to == null) taskInstance.duration.last.to = TimeDate.now();
		else taskInstance.breaks.last.to = TimeDate.now();
		taskInstance.status.state = TaskState.notEvaluated;
		taskInstance.status.completed = true;
		await _dataRepository.updateTaskInstance(taskInstance);
		if(await _dataRepository.getCompletedTaskCount(planInstance.id) == planInstance.taskInstances.length) {
			List<TaskInstance> allTaskInstances = await _dataRepository.getTaskInstances(planInstanceId: planInstance.id);
			bool isCompleted = true;
			for(var task in allTaskInstances) {
				if(task.status.state == TaskState.rejected) isCompleted = false;
			}
			if(isCompleted) planInstance.state = PlanInstanceState.completed;
		}

		await _dataRepository.updatePlanInstance(planInstance);
		Task task = await _dataRepository.getTask(taskId: taskInstance.taskID);
		UITaskInstance uiTaskInstance = UITaskInstance.singleFromDBModel(task: taskInstance, name: task.name, description: task.description, points: task.points != null ? UIPoints(quantity: task.points.quantity, title: task.points.name, createdBy: task.points.createdBy, type: task.points.icon) : null);

		_activeTaskService.setTaskStateInactive();
		emit(TaskInstanceStateDone(uiTaskInstance, await _getUiPlanInstance(taskInstance.planInstanceID)));
	}

	void markAsRejected() async {
		TaskInstance taskInstance = await _dataRepository.getTaskInstance(taskInstanceId: _taskInstanceId);
		PlanInstance planInstance = await _dataRepository.getPlanInstance(id: taskInstance.planInstanceID);
		planInstance.duration.last.to = TimeDate.now();
		await _dataRepository.updatePlanInstance(planInstance);
		if(taskInstance.duration.last.to == null) taskInstance.duration.last.to = TimeDate.now();
		else taskInstance.breaks.last.to = TimeDate.now();
		taskInstance.status.state = TaskState.rejected;
		taskInstance.status.completed = true;
		await _dataRepository.updateTaskInstance(taskInstance);
		Task task = await _dataRepository.getTask(taskId: taskInstance.taskID);
		UITaskInstance uiTaskInstance = UITaskInstance.singleFromDBModel(task: taskInstance, name: task.name, description: task.description, points: task.points != null ? UIPoints(quantity: task.points.quantity, title: task.points.name, createdBy: task.points.createdBy, type: task.points.icon) : null);

		_activeTaskService.setTaskStateInactive();
		emit(TaskInstanceStateRejected(uiTaskInstance, await _getUiPlanInstance(taskInstance.planInstanceID)));
	}

	Future<UIPlanInstance> _getUiPlanInstance(ObjectId id) async {
		var getDescription = (Plan plan, [Date instanceDate]) => _repeatabilityService.buildPlanDescription(plan.repeatability, instanceDate: instanceDate);
		PlanInstance planInstance = await _dataRepository.getPlanInstance(id: id);

		var plan = await _dataRepository.getPlan(id: planInstance.planID);
		var elapsedTime = () => sumDurations(planInstance.duration).inSeconds;
		var completedTasks = await _dataRepository.getCompletedTaskCount(planInstance.id);
		return UIPlanInstance.fromDBModel(planInstance, plan.name, completedTasks, elapsedTime, getDescription(plan, planInstance.date));
	}
}
