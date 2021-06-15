import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/child_card_model.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UIDataAggregator {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

	Future<ChildCardModel> loadChildCard(ObjectId id) async => (await loadChildCards([await _dataRepository.getUser(id: id) as Child]))[0];

	Future<List<ChildCardModel>> loadChildCards(List<Child> children) async {
		var data = await Future.wait([
			...children.map((child) => _repeatabilityService.getPlanCountByDate(child.id!, Date.now())),
			...children.map((child) => _dataRepository.hasActiveChildPlanInstance(child.id!))
		]);
		List<ChildCardModel> childList = [];
		for (int i = 0; i < children.length; i++)
			childList.add(ChildCardModel(child: children[i], todayPlanCount: data[i] as int, hasActivePlan: data[children.length + i] as bool));
		return childList;
	}

	Future<UIPlanInstance> loadPlanInstance({PlanInstance? planInstance, ObjectId? planInstanceId, Plan? plan}) async {
		planInstance ??= await _dataRepository.getPlanInstance(id: planInstanceId);
		var completedTasks = await _dataRepository.getCompletedTaskCount(planInstance!.id!);
		plan ??= await _dataRepository.getPlan(id: planInstance.planID!, fields: ['_id', 'repeatability', 'name']);
		var getDescription = (Plan plan, [Date? instanceDate]) => PlanRepeatabilityService.buildPlanDescription(plan.repeatability!, instanceDate: instanceDate);
		var elapsedTime = () => sumDurations(planInstance!.duration).inSeconds;
		return UIPlanInstance.fromDBModel(planInstance, plan!.name!, completedTasks, elapsedTime, (_) => getDescription(plan!, planInstance?.date));
	}

	Future<List<UIPlanInstance>> loadTodaysPlanInstances({required ObjectId childId}) async {
		var planFields = ['_id', 'name', 'repeatability'];

		var instances = await _dataRepository.getPlanInstances(childIDs: [childId], date: Date.now());
		var plans = await _dataRepository.getPlans(ids: instances.map((plan) => plan.planID!).toList(), fields: planFields);
		var untilCompletedPlans = await _dataRepository.getPlans(childId: childId, untilCompleted: true, active: true, fields: planFields);
		plans.addAll(untilCompletedPlans);
		instances.addAll(await _dataRepository.getPastNotCompletedPlanInstances([childId], untilCompletedPlans.map((plan) => plan.id!).toList(), Date.now()));
		return getUIPlanInstances(plans: plans, instances: instances);
	}

	Future<List<UIPlanInstance>> getUIPlanInstances({required List<Plan> plans, required List<PlanInstance> instances}) async {
		var getDescription = (Plan plan, [Date? instanceDate]) => PlanRepeatabilityService.buildPlanDescription(plan.repeatability!, instanceDate: instanceDate);
		var planMap = Map.fromEntries(instances.map((instance) => MapEntry(instance.id, plans.firstWhere((plan) => plan.id == instance.planID))));

		List<UIPlanInstance> uiInstances = [];
		for (var instance in instances) {
			var elapsedTime = () => sumDurations(instance.duration).inSeconds;
			var completedTasks = await _dataRepository.getCompletedTaskCount(instance.id!);
			uiInstances.add(UIPlanInstance.fromDBModel(
				instance,
				planMap[instance.id]!.name!,
				completedTasks,
				elapsedTime,
				(_) => getDescription(planMap[instance.id]!, instance.date)
			));
		}
		return uiInstances;
	}
}
