import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/ui/child_card_model.dart';
import 'package:fokus/services/ui_data_aggregator.dart';
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
import 'package:fokus/model/ui/plan/ui_task_instance.dart';
import 'package:fokus/model/ui/plan/ui_task_report.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/task_instance_service.dart';

class TasksEvaluationCubit extends StatefulCubit {
  final DataRepository _dataRepository = GetIt.I<DataRepository>();
  final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
  final TaskInstanceService _taskInstanceService = GetIt.I<TaskInstanceService>();
  final NotificationService _notificationService = GetIt.I<NotificationService>();
  final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();

	late List<UITaskInstance> _uiTaskInstances;
  List<UITaskReport> _completedReports = [];
	late Map<ObjectId, ChildCardModel> _planInstanceToChild;
	late Map<ObjectId, String> _planInstanceToName;

	TasksEvaluationCubit(ModalRoute pageRoute) : super(pageRoute);

  @override
  List<NotificationType> notificationTypeSubscription() => [NotificationType.taskFinished];

	@override
	Future doLoadData() async {
		var user = activeUser as Caregiver;
		Iterable<Child> children = (await _dataRepository.getUsers(ids: user.connections)).map((e) => e as Child);
		List<ChildCardModel> childCards = await _dataAggregator.loadChildCards(children.toList());
		var _childMap = Map.fromEntries(childCards.map((childCard) => MapEntry(childCard.child.id!, childCard)));
		List<PlanInstance> planInstances = await _dataRepository.getPlanInstances(childIDs: _childMap.keys.toList(), fields: ['_id', 'assignedTo', 'planID']);
		_planInstanceToChild = Map.fromEntries(planInstances.map((planInstance) => MapEntry(planInstance.id!, _childMap[planInstance.assignedTo]!)));
		List<TaskInstance> taskInstances = await _dataRepository.getTaskInstances(planInstancesId: _planInstanceToChild.keys.toList(),
				isCompleted: true, state: TaskState.notEvaluated, fields:['_id', 'taskID', 'planInstanceID', 'duration', 'breaks', 'timer', 'status']);
		var nameMap = Map.fromEntries((await _dataRepository.getPlans(ids: planInstances.map((planInstance) => planInstance.planID!).toSet().toList(),
				fields:['name', '_id'])).map((plan) => MapEntry(plan.id, plan.name)));
		_uiTaskInstances = taskInstances.isNotEmpty ? await _taskInstanceService.mapToUIModels(taskInstances, shouldGetTaskStatus: false) : [];
		_planInstanceToName = Map.fromEntries(planInstances.map((planInstance) => MapEntry(planInstance.id!, nameMap[planInstance.planID]!)));
		List<UITaskReport> _reports = _uiTaskInstances.map((taskInstance) => UITaskReport(
			planName: _planInstanceToName[taskInstance.instance.planInstanceID]!,
			uiTask: taskInstance,
			childCard: _planInstanceToChild[taskInstance.instance.planInstanceID]!,
		)).toList();
		emit(TasksEvaluationState(reports: _reports..addAll(_completedReports)));
	}

	Future rateTask(UITaskReport report) async {
		if (!beginSubmit())
			return;
		_completedReports.add(report);
		List<Future> updates = [];
		Future Function() sendNotification;
		if(report.ratingMark == UITaskReportMark.rejected) {
			sendNotification = () => _notificationService.sendTaskRejectedNotification(report.uiTask.instance.planInstanceID!, report.uiTask.task.name!, report.childCard.child.id!);
			updates.add(_dataRepository.updatePlanInstanceFields(report.uiTask.instance.planInstanceID!, state: PlanInstanceState.notCompleted));
			updates.add(_dataRepository.updateTaskInstanceFields(report.uiTask.instance.id!, state:TaskState.rejected));
			_analyticsService.logTaskRejected(report);
		} else {
			int? pointsAwarded;
			bool hasPoints = report.uiTask.task.points != null;
			if(hasPoints)
				pointsAwarded = getPointsAwarded(report.uiTask.task.points!.quantity!, report.ratingMark.value!);
			updates.add(_dataRepository.updateTaskInstanceFields(report.uiTask.task.id!, state: TaskState.evaluated,
					rating: report.ratingMark.value, pointsAwarded: pointsAwarded, ratingComment: report.ratingComment));
			if (hasPoints) {
			  var child = await _dataRepository.getUser(id: report.childCard.child.id!) as Child;
			  List<Points> points = child.points!;
			  var pointIndex = points.indexWhere((element) => element.type == report.uiTask.task.points!.type);
			  if(pointIndex > -1)
			  	points[pointIndex] = points[pointIndex].copyWith(quantity: points[pointIndex].quantity! + pointsAwarded!);
		    else
				  points.add(Points.fromCurrency(currency: report.uiTask.task.points!, quantity: pointsAwarded!, createdBy: report.uiTask.task.points?.createdBy));
				updates.add(_dataRepository.updateUser(child.id!, points: points));
			}
			_analyticsService.logTaskApproved(report);
			sendNotification = () => _notificationService.sendTaskApprovedNotification(
				report.uiTask.instance.planInstanceID!,
				report.uiTask.task.name!,
				report.childCard.child.id!,
				report.ratingMark.value!,
				currencyType: report.uiTask.task.points?.type,
				pointCount: pointsAwarded,
				comment: report.ratingComment
			);
		}
		await Future.wait(updates);
		await sendNotification();
		return emit(state.submissionSuccess());
	}

	static int getPointsAwarded(int quantity, int ratingMark) => max((quantity * ratingMark / 5).round(), 1);
}

class TasksEvaluationState extends StatefulState {
	final List<UITaskReport> reports;

	TasksEvaluationState({required this.reports, DataSubmissionState? submissionState}) : super.loaded(submissionState);

	@override
	StatefulState withSubmitState(DataSubmissionState submissionState) => TasksEvaluationState(reports: reports, submissionState: submissionState);

  @override
	List<Object?> get props => super.props..add(reports);
}
