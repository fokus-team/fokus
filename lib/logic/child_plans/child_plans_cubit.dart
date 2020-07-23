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
	  var getDescription = (Plan plan) => _repeatabilityService.buildPlanDescription(plan.repeatability);
	  var childId = (_activeUserCubit.state as ActiveUserPresent).user.id;
	  var plans = await _repeatabilityService.getChildPlansByDate(childId, Date.now());
	  var instances = await _dbRepository.getPlanInstancesForPlans(childId, plans.map((plan) => plan.id).toList());
	  var planMap = Map.fromEntries(instances.map((instance) => MapEntry(instance, plans.firstWhere((plan) => plan.id == instance.planID))));

	  List<UIPlanInstance> uiInstances = [];
	  for (int i = 0; i < instances.length; i++)
	  	if (instances[i].state == PlanInstanceState.active || instances[i].state == PlanInstanceState.notCompleted) {
			  var elapsedTime = DateTime.now().difference(instances[i].duration.from).inMinutes;
			  var completedTasks = await _dbRepository.getCompletedTaskCount(instances[i].id);
	  		uiInstances.add(UIPlanInstance.fromDBModel(instances[i], planMap[instances[i]].name, completedTasks, elapsedTime, getDescription(planMap[instances[i]])));
	  		instances.removeAt(i);
		  }
	  uiInstances.addAll(instances.map((instance) => UIPlanInstance.fromDBModel(instance, planMap[instance].name, 0, 0, getDescription(planMap[instance]))));
	  uiInstances.addAll(plans.where((plan) => !planMap.values.contains(plan)).map((plan) => UIPlanInstance.fromDBPlanModel(plan, getDescription(plan))));
	  emit(ChildPlansLoadSuccess(uiInstances));
  }
}
