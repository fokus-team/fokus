import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/model/ui/task/ui_task_report.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/task_instance_service.dart';

class TasksEvaluationCubit extends StatefulCubit {
  final DataRepository _dataRepository = GetIt.I<DataRepository>();
  final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
  final TaskInstanceService _taskInstanceService = GetIt.I<TaskInstanceService>();
  final NotificationService _notificationService = GetIt.I<NotificationService>();

	final ActiveUserFunction _activeUser;
	List<UITaskInstance> _uiTaskInstances;
	List<UITaskReport> _reports = [];
	Map<ObjectId, UIChild> _planInstanceToChild;
	Map<ObjectId, String> _planInstanceToName;

	TasksEvaluationCubit(ModalRoute pageRoute, this._activeUser) : super(pageRoute, options: [StatefulOption.repeatableSubmission]);

  @override
  List<NotificationType> dataTypeSubscription() => [NotificationType.taskFinished];

	@override
	Future doLoadData() async {
		_reports = [];
		var activeUser = _activeUser();
		List<Child> children = (await _dataRepository.getUsers(ids: (activeUser as UICaregiver).connections, fields: ['_id', 'name', 'avatar'])).map((e) => e as Child).toList();
		var _childMap = Map.fromEntries(children.map((child) => MapEntry(child.id, child)));
		List<PlanInstance> planInstances = await _dataRepository.getPlanInstances(childIDs: _childMap.keys.toList(), fields: ['_id', 'assignedTo', 'planID']);
		_planInstanceToChild = Map.fromEntries(planInstances.map((planInstance) => MapEntry(planInstance.id, UIChild(planInstance.assignedTo, _childMap[planInstance.assignedTo].name, avatar: _childMap[planInstance.assignedTo].avatar))));
		List<TaskInstance> taskInstances = await _dataRepository.getTaskInstances(planInstancesId: _planInstanceToChild.keys.toList(), isCompleted: true, state: TaskState.notEvaluated, fields:['_id', 'taskID', 'planInstanceID', 'duration', 'breaks', 'timer', 'status']);
		var nameMap = Map.fromEntries((await _dataRepository.getPlans(ids: planInstances.map((planInstance) => planInstance.planID).toSet().toList(), fields:['name', '_id'])).map((plan) => MapEntry(plan.id, plan.name)));
		_uiTaskInstances = taskInstances.isNotEmpty ? await _taskInstanceService.mapToUIModels(taskInstances, shouldGetTaskStatus: false) : [];
		_planInstanceToName = Map.fromEntries(planInstances.map((planInstance) => MapEntry(planInstance.id, nameMap[planInstance.planID])));
		for(var taskInstance in _uiTaskInstances) {
			_reports.add(UITaskReport(
				planName: _planInstanceToName[taskInstance.planInstanceId],
				task: taskInstance,
				child: _planInstanceToChild[taskInstance.planInstanceId],
			));
		}
		emit(TasksEvaluationState(_reports));
	}

	void rateTask(UITaskReport report) async {
		if (!beginSubmit())
			return;
		List<Future> updates = [];
		Future Function() sendNotification;
		if(report.ratingMark == UITaskReportMark.rejected) {
			sendNotification = () => _notificationService.sendTaskRejectedNotification(report.task.planInstanceId, report.task.name, report.child.id);
			updates.add(_dataRepository.updatePlanInstanceFields(report.task.planInstanceId, state: PlanInstanceState.notCompleted));
			updates.add(_dataRepository.updateTaskInstanceFields(report.task.id, state:TaskState.rejected));
			_analyticsService.logTaskRejected(report);
		} else {
			int pointsAwarded;
			bool hasPoints = report.task.points != null;
			if(hasPoints)
				pointsAwarded =  getPointsAwarded(report.task.points.quantity, report.ratingMark.value);
			updates.add(_dataRepository.updateTaskInstanceFields(report.task.id, state: TaskState.evaluated, rating: report.ratingMark.value, pointsAwarded: pointsAwarded));
			if (hasPoints) {
			  Child child = await _dataRepository.getUser(id: report.child.id);
			  List<Points> newPoints = child.points;
			  if(newPoints != null && newPoints.isNotEmpty && newPoints.any((element) => element.icon == report.task.points.type)) {
					newPoints.singleWhere((element) => element.icon == report.task.points.type).quantity += pointsAwarded;
			  } else {
			  	if(newPoints == null) newPoints = [];
					newPoints.add(Points.fromUICurrency(report.task.points, pointsAwarded, creator: report.task.points.createdBy));
			  }
				updates.add(_dataRepository.updateUser(child.id, points: newPoints));
			}
			_analyticsService.logTaskApproved(report);
			sendNotification = () =>  _notificationService.sendTaskApprovedNotification(report.task.planInstanceId, report.task.name, report.child.id,
					report.ratingMark.value, hasPoints ? report.task.points.type : null, hasPoints ? pointsAwarded : null);
		}
		await Future.wait(updates);
		await sendNotification();
		return emit(state.submissionSuccess());
	}

	static int getPointsAwarded(int quantity, int ratingMark) => max((quantity*ratingMark/5).round(), 1);
}

class TasksEvaluationState extends StatefulState {
	final List<UITaskReport> reports;

	TasksEvaluationState(this.reports, [DataSubmissionState submissionState]) : super.loaded(submissionState);

	@override
  StatefulState withSubmitState(DataSubmissionState submissionState) => TasksEvaluationState(reports, submissionState);

  @override
	List<Object> get props => super.props..addAll([reports]);
}
