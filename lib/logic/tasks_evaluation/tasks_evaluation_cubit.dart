import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/model/ui/task/ui_task_report.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/services/task_instance_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'tasks_evaluation_state.dart';

class TasksEvaluationCubit extends Cubit<TasksEvaluationState> {
  final DataRepository _dataRepository = GetIt.I<DataRepository>();
  final TaskInstanceService _taskInstanceService = GetIt.I<TaskInstanceService>();
	final ActiveUserFunction _activeUser;
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();
	Map<ObjectId, String> _childNames;
	final String _key = 'lastCheck';
	final String _idList = 'taskInstancesList';
	List<UITaskInstance> _uiTaskInstances;
	List<UIChild> _childrenList;
	List<String> _planNames;


	TasksEvaluationCubit(this._activeUser) : super(TasksEvaluationInitial());

	void loadData() async {
		var activeUser = _activeUser();
		var children = await _dataRepository.getUsers(ids: (activeUser as UICaregiver).connections);
		_childNames = Map.fromEntries(children.map((child) => MapEntry(child.id, child.name)));
		DateSpan<Date> dateSpan = DateSpan();
		final prefs = await SharedPreferences.getInstance();
		if(prefs.containsKey(_key))
			dateSpan.from = Date.fromDate(DateTime.parse(prefs.getString(_key)));
		else dateSpan.from = Date.fromDate(DateTime.now().subtract(Duration(days: 7)));
		dateSpan.to = Date.now();

		var tasksInstances = await _loadSavePastData(dateSpan);
		_uiTaskInstances = [];
		if(tasksInstances.isNotEmpty) _uiTaskInstances = await _taskInstanceService.mapToUIModels(tasksInstances);
		_planNames = [];
		_childrenList = [];
		Map<ObjectId, Child> childrenChild = {};
		Map<ObjectId, int> childrenPlans = {};
		Map<ObjectId, ObjectId> planInstanceToPlan = {};
		Map<ObjectId, String> planToName = {};
		Map<ObjectId, ObjectId> planToChild = {};

		for(TaskInstance taskInstance in tasksInstances) {
			if(!planInstanceToPlan.containsKey(taskInstance.planInstanceID)) {
				var planInstanceTemp = await _dataRepository.getPlanInstance(id: taskInstance.planInstanceID);
				planInstanceToPlan[taskInstance.planInstanceID] = planInstanceTemp.planID;
				if(!planToChild.containsKey(taskInstance.planInstanceID))
					planToChild[taskInstance.planInstanceID] = planInstanceTemp.assignedTo;
			}

			if(!planToName.containsKey(planInstanceToPlan[taskInstance.planInstanceID]))
				planToName[planInstanceToPlan[taskInstance.planInstanceID]] = (await _dataRepository.getPlan(id: planInstanceToPlan[taskInstance.planInstanceID])).name;
			_planNames.add(planToName[planInstanceToPlan[taskInstance.planInstanceID]]);

			if(!childrenPlans.containsKey(planToChild[taskInstance.planInstanceID])) {
				var plans = await _repeatabilityService.getPlansByDate(planToChild[taskInstance.planInstanceID], Date.now());
				childrenPlans[planToChild[taskInstance.planInstanceID]] = plans.length;
			}
			if(!childrenChild.containsKey(planToChild[taskInstance.planInstanceID]))
				childrenChild[planToChild[taskInstance.planInstanceID]] = await _dataRepository.getUser(id: planToChild[taskInstance.planInstanceID]);
			_childrenList.add(UIChild.fromDBModel(
				childrenChild[planToChild[taskInstance.planInstanceID]],
				todayPlanCount: childrenPlans[planToChild[taskInstance.planInstanceID]],
				hasActivePlan: false));
		}
		emit(TasksEvaluationLoadSuccess(_uiTaskInstances, _childrenList, _planNames));
	}

	void rateTask(UITaskReport report) async {
		//updateTaskInstance
		TaskInstance taskInstance = await _dataRepository.getTaskInstance(taskInstanceId: report.task.id);
		PlanInstance planInstance = await _dataRepository.getPlanInstance(id: taskInstance.planInstanceID);
		Task task = await _dataRepository.getTask(taskId: taskInstance.taskID);
		if(report.ratingMark == UITaskReportMark.rejected) {
			taskInstance.status.state = TaskState.rejected;
			planInstance.state = PlanInstanceState.notCompleted;
			_dataRepository.updatePlanInstance(planInstance);

		} else {
			taskInstance.status.state = TaskState.evaluated;
			taskInstance.status.rating = report.ratingMark.value;
			taskInstance.status.pointsAwarded = (report.task.points.quantity*report.ratingMark.value/5).round();
			Child child = await _dataRepository.getUser(id: planInstance.assignedTo);
			if(child.points != null && child.points.any((element) => element.createdBy == task.points.createdBy && element.icon == task.points.icon)) {
				child.points.firstWhere((element) => element.createdBy == task.points.createdBy && element.icon == task.points.icon).quantity += taskInstance.status.pointsAwarded;
			} else {
				if(child.points == null) child.points = [];
				child.points.add(task.points);
			}
			_dataRepository.updateUser(child.id, points: child.points);
		}
		//_dataRepository.updateTaskInstance();

		emit(TasksEvaluationSubmissionSuccess([], [], []));
	}


	Future<List<TaskInstance>> _loadSavePastData(DateSpan<Date> span) async {
		var instances = await _dataRepository.getPlanInstances(childIDs: _childNames.keys.toList(), between: span);
		List<TaskInstance> taskInstances = [];
		for(var instance in instances) {
			List<TaskInstance> past = await _dataRepository.getTaskInstances(planInstanceId: instance.id);
			if(past != null)
				taskInstances.addAll(past.where((element) => element.status.completed == true && element.status.state == TaskState.notEvaluated));
		}
		final prefs = await SharedPreferences.getInstance();
		if(prefs.containsKey(_idList)) {
			List<String> ids = prefs.getStringList(_idList);
			if(ids.isNotEmpty) {
				taskInstances.addAll(await _dataRepository.getTaskInstancesFromIds(taskInstancesIds: ids.map((e) => ObjectId.parse(e)).toList()));
			}
		}
		prefs.setString(_key, Date.now().toString());
		if(taskInstances.isNotEmpty) prefs.setStringList(_idList, taskInstances.map((e) => e.id.toHexString()).toList());
		return taskInstances;
	}
}
