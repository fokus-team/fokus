import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/model/ui/task/ui_task_report.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/task_instance_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'tasks_evaluation_state.dart';

class TasksEvaluationCubit extends Cubit<TasksEvaluationState> {
  final DataRepository _dataRepository = GetIt.I<DataRepository>();
  final TaskInstanceService _taskInstanceService = GetIt.I<TaskInstanceService>();
	final ActiveUserFunction _activeUser;
	List<UITaskInstance> _uiTaskInstances;
	Map<ObjectId, UIChild> _planInstanceToChild;
	Map<ObjectId, String> _planInstanceToName;


	TasksEvaluationCubit(this._activeUser) : super(TasksEvaluationInitial());

	void loadData() async {
		var activeUser = _activeUser();
		List<Child> children = (await _dataRepository.getUsers(ids: (activeUser as UICaregiver).connections, fields: ['_id', 'name', 'avatar'])).map((e) => e as Child).toList();
		var _childMap = Map.fromEntries(children.map((child) => MapEntry(child.id, child)));
		List<PlanInstance> planInstances = await _dataRepository.getPlanInstances(childIDs: _childMap.keys.toList(), fields: ['_id', 'assignedTo', 'planID']);
		_planInstanceToChild = Map.fromEntries(planInstances.map((planInstance) => MapEntry(planInstance.id, UIChild(planInstance.assignedTo, _childMap[planInstance.assignedTo].name, avatar: _childMap[planInstance.assignedTo].avatar))));
		List<TaskInstance> taskInstances = await _dataRepository.getTaskInstances(planInstancesId: _planInstanceToChild.keys.toList(), isCompleted: true, state: TaskState.notEvaluated, fields:['_id', 'taskID', 'planInstanceID', 'duration', 'breaks', 'timer', 'status']);
		var nameMap = Map.fromEntries((await _dataRepository.getPlans(ids: planInstances.map((planInstance) => planInstance.planID).toSet().toList(), fields:['name', '_id'])).map((plan) => MapEntry(plan.id, plan.name)));
		if(taskInstances.isNotEmpty) _uiTaskInstances = await _taskInstanceService.mapToUIModels(taskInstances, shouldGetTaskStatus: false);
		else _uiTaskInstances = [];
		_planInstanceToName = Map.fromEntries(planInstances.map((planInstance) => MapEntry(planInstance.id, nameMap[planInstance.planID])));

		emit(TasksEvaluationLoadSuccess(_uiTaskInstances, _planInstanceToChild, _planInstanceToName));
	}

	void rateTask(UITaskReport report) async {
		List<Future> updates = [];
		int i = _uiTaskInstances.indexOf(_uiTaskInstances.singleWhere((uiTaskInstance) => uiTaskInstance.id == report.task.id));
		if(report.ratingMark == UITaskReportMark.rejected) {
			updates.add(_dataRepository.updatePlanInstanceFields(_uiTaskInstances[i].planInstanceId, state: PlanInstanceState.notCompleted));
			updates.add(_dataRepository.updateTaskInstanceFields(report.task.id, state:TaskState.rejected));
		} else {
			int pointsAwarded;
			if(report.task.points != null)
				pointsAwarded =  max((report.task.points.quantity*report.ratingMark.value/5).round(), 1);
			updates.add(_dataRepository.updateTaskInstanceFields(report.task.id, state: TaskState.evaluated, rating: report.ratingMark.value, pointsAwarded: pointsAwarded));
			if (report.task.points != null) {
			  Child child = await _dataRepository.getUser(id: report.child.id);
			  List<Points> newPoints = child.points;
			  if(newPoints != null && newPoints.isNotEmpty && newPoints.any((element) => element.icon == _uiTaskInstances[i].points.type)) {
					newPoints.singleWhere((element) => element.icon == _uiTaskInstances[i].points.type).quantity += pointsAwarded;
			  } else {
			  	if(newPoints == null) newPoints = [];
					newPoints.add(Points.fromUICurrency(_uiTaskInstances[i].points, pointsAwarded, creator: _uiTaskInstances[i].points.createdBy));
			  }
				updates.add(_dataRepository.updateUser(child.id, points: newPoints));
			}
		}
		await Future.wait(updates);
		emit(TasksEvaluationSubmissionSuccess(_uiTaskInstances, _planInstanceToChild, _planInstanceToName));
	}
}
