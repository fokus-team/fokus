import 'package:cubit/cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/services/plan_repeatability_service.dart';

part 'child_plans_state.dart';

class ChildPlansCubit extends Cubit<ChildPlansState> {
	final ActiveUserCubit _activeUserCubit;
	final DataRepository _dbProvider = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  ChildPlansCubit(this._activeUserCubit) : super(ChildPlansInitial());

  void loadChildPlansForToday() async {
	  if (!(state is ChildPlansInitial))
		  return;
	  var userId = (_activeUserCubit.state as ActiveUserPresent).user.id;
	  emit(ChildPlansLoadInProgress());
		var plans = await _repeatabilityService.getChildPlansByDate(userId, Date.now());
		var activePlanInstance = await _dbProvider.getActiveChildPlanInstance(userId);
		Plan activePlan;
		if (activePlanInstance != null) {
			activePlan = plans.firstWhere((plan) => plan.id == activePlanInstance.planID);
			plans.remove(activePlan);
		}
		emit(ChildPlansLoadSuccess(
				plans: plans.map((plan) => _createUIPlan(plan)).toList(),
				activePlan: activePlan != null ? _createUIPlan(activePlan) : null
		));
  }

  UIPlan _createUIPlan(Plan plan) => UIPlan.fromDBModel(plan, _repeatabilityService.buildPlanDescription(plan.repeatability));
}
