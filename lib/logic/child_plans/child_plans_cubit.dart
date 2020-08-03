import 'package:cubit/cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';

part 'child_plans_state.dart';

class ChildPlansCubit extends Cubit<ChildPlansState> {
	final ActiveUserCubit _activeUserCubit;
	final DataRepository _dbRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  ChildPlansCubit(this._activeUserCubit) : super(ChildPlansInitial());

  void loadChildPlansForToday() async {
	  if (!(state is ChildPlansInitial))
		  return;
	  var getDescription = (Plan plan, [Date instanceDate]) => _repeatabilityService.buildPlanDescription(plan.repeatability, instanceDate: instanceDate);
	  var childId = (_activeUserCubit.state as ActiveUserPresent).user.id;

	  var allPlans = await _dbRepository.getPlans(childId: childId);
	  var todayPlans = await _repeatabilityService.filterPlansByDate(allPlans, Date.now());
	  var todayPlanIds = todayPlans.map((plan) => plan.id).toList();
	  var untilCompletedPlans = allPlans.where((plan) => plan.repeatability.untilCompleted && !todayPlans.contains(plan.id)).map((plan) => plan.id).toList();

	  var instances = await _dbRepository.getPlanInstancesForPlans(childId, todayPlanIds, Date.now());
	  instances.addAll(await _dbRepository.getPastNotCompletedPlanInstances([childId], untilCompletedPlans, Date.now()));
	  var planMap = Map.fromEntries(instances.map((instance) => MapEntry(instance, allPlans.firstWhere((plan) => plan.id == instance.planID))));

	  List<UIPlanInstance> uiInstances = [];
	  for (var instance in instances) {
		  var elapsedTime = () => 0;
		  if (instance.state == PlanInstanceState.active || instance.state == PlanInstanceState.notCompleted) {
			  elapsedTime = () => DateTime.now().difference(instance.duration.from).inSeconds;
		  } else if (instance.state == PlanInstanceState.completed)
		  	elapsedTime = () => instance.duration.to.difference(instance.duration.from).inSeconds;
		  var completedTasks = await _dbRepository.getCompletedTaskCount(instance.id);
		  uiInstances.add(UIPlanInstance.fromDBModel(instance, planMap[instance].name, completedTasks, elapsedTime, getDescription(planMap[instance], instance.date)));
	  }
	  uiInstances.addAll(todayPlans.where((plan) => !planMap.values.contains(plan)).map((plan) => UIPlanInstance.fromDBPlanModel(plan, getDescription(plan))));
	  emit(ChildPlansLoadSuccess(uiInstances));
  }
}
