import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:get_it/get_it.dart';

part 'caregiver_plans_state.dart';

class CaregiverPlansCubit extends Cubit<CaregiverPlansState> {
  final ActiveUserCubit _activeUserCubit;
  final DataRepository _dbRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  CaregiverPlansCubit(this._activeUserCubit) : super(CaregiverPlansInitial());

  loadCaregiverPlans() async {
    if (!(state is CaregiverPlansInitial)) return;

    var getDescription = (Plan plan) => _repeatabilityService.buildPlanDescription(plan.repeatability);
    var caregiverId = (_activeUserCubit.state as ActiveUserPresent).user.id;
    var plans = await _dbRepository.getPlans(caregiverId: caregiverId, activeOnly: false);

    List<UIPlan> uiPlans = [];
    for(int i=0;i<plans.length;i++) {
				uiPlans.add(UIPlan.fromDBModel(plans[i], getDescription(plans[i])));
		}
		emit(CaregiverPlansLoadSuccess(uiPlans));
  }
}
