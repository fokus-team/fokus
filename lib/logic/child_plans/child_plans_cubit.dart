import 'package:cubit/cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/ui_plan.dart';
import 'package:fokus/services/plan_repeatability_service.dart';

part 'child_plans_state.dart';

class ChildPlansCubit extends Cubit<ChildPlansState> {
	final ActiveUserCubit _activeUserCubit;
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  ChildPlansCubit(this._activeUserCubit) : super(ChildPlansInitial());

  void loadChildPlansForToday() async {
	  emit(ChildPlansLoadInProgress());
		var plans = await _repeatabilityService.getChildPlansByDate((_activeUserCubit.state as ActiveUserPresent).user.id, Date.now());
		emit(ChildPlansLoadSuccess(plans.map((plan) => UIPlan.fromDBModel(plan)).toList()));
  }
}
