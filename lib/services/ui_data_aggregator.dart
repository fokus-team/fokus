import 'package:flutter/cupertino.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UIDataAggregator {
	final Logger _logger = Logger('PlanInstanceService');

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

	Future<UIChild> loadChild(ObjectId id) async => (await loadChildren([await _dataRepository.getUser(id: id) as Child]))[0];

	Future<List<UIChild>> loadChildren(List<Child> children) async {
		var data = await Future.wait([
			...children.map((child) => _repeatabilityService.getPlanCountByDate(child.id, Date.now())),
			...children.map((child) => _dataRepository.hasActiveChildPlanInstance(child.id))
		]);
		List<UIChild> childList = [];
		for (int i = 0; i < children.length; i++)
			childList.add(UIChild.fromDBModel(children[i], todayPlanCount: data[i], hasActivePlan: data[children.length + i]));
		return childList;
	}

	Future<UIPlanInstance> loadPlanInstance({PlanInstance planInstance, ObjectId planInstanceId, Plan plan}) async {
		planInstance ??= await _dataRepository.getPlanInstance(id: planInstanceId);
		var completedTasks = await _dataRepository.getCompletedTaskCount(planInstance.id);
		plan ??= await _dataRepository.getPlan(id: planInstance.planID, fields: ['_id', 'repeatability', 'name']);
		var getDescription = (Plan plan, [Date instanceDate]) => _repeatabilityService.buildPlanDescription(plan.repeatability, instanceDate: instanceDate);
		var elapsedTime = () => sumDurations(planInstance.duration).inSeconds;
		return UIPlanInstance.fromDBModel(planInstance, plan.name, completedTasks, elapsedTime, getDescription(plan, planInstance.date));
	}

	Future<List<UIPlanInstance>> loadPlanInstances({@required ObjectId childId, List<Plan> plans}) async {
		var getDescription = (Plan plan, [Date instanceDate]) => _repeatabilityService.buildPlanDescription(plan.repeatability, instanceDate: instanceDate);

		var allPlans = (plans ?? await _dataRepository.getPlans(childId: childId)).where((plan) => plan.active).toList();
		var todayPlans = _repeatabilityService.filterPlansByDate(allPlans, Date.now());
		var todayPlanIds = todayPlans.map((plan) => plan.id).toList();
		var untilCompletedPlans = allPlans.where((plan) => plan.repeatability.untilCompleted && !todayPlans.contains(plan.id)).map((plan) => plan.id).toList();

		var instances = await _dataRepository.getPlanInstancesForPlans(childId, todayPlanIds, Date.now());
		instances.addAll(await _dataRepository.getPastNotCompletedPlanInstances([childId], untilCompletedPlans, Date.now()));
		var planMap = Map.fromEntries(instances.map((instance) => MapEntry(instance, allPlans.firstWhere((plan) => plan.id == instance.planID))));

		List<UIPlanInstance> uiInstances = [];
		for (var instance in instances) {
			var elapsedTime = () => sumDurations(instance.duration).inSeconds;
			var completedTasks = await _dataRepository.getCompletedTaskCount(instance.id);
			uiInstances.add(UIPlanInstance.fromDBModel(instance, planMap[instance].name, completedTasks, elapsedTime, getDescription(planMap[instance], instance.date)));
		}
		var noInstancePlans = todayPlans.where((plan) => !planMap.values.contains(plan)).toList();
		if (noInstancePlans.isNotEmpty)
			_logger.warning('${noInstancePlans.length} plans have no instances: ' + noInstancePlans.map((plan) => plan.name).join(', '));
		return uiInstances;
	}
}
