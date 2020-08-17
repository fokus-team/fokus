import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/utils/duration_utils.dart';

part 'child_plans_state.dart';

class ChildPlansCubit extends Cubit<ChildPlansState> {
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  ChildPlansCubit(this._activeUser) : super(ChildPlansInitial());

  void loadChildPlansForToday() async {
	  if (!(state is ChildPlansInitial))
		  return;
	  var getDescription = (Plan plan, [Date instanceDate]) => _repeatabilityService.buildPlanDescription(plan.repeatability, instanceDate: instanceDate);
	  var childId = _activeUser().id;

	  var allPlans = await _dataRepository.getPlans(childId: childId);
	  var todayPlans = await _repeatabilityService.filterPlansByDate(allPlans, Date.now());
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
	  uiInstances.addAll(todayPlans.where((plan) => !planMap.values.contains(plan)).map((plan) => UIPlanInstance.fromDBPlanModel(plan, getDescription(plan))));
	  emit(ChildPlansLoadSuccess(uiInstances));
  }
}
