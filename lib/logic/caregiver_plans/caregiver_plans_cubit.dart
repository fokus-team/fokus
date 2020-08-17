import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';

part 'caregiver_plans_state.dart';

class CaregiverPlansCubit extends Cubit<CaregiverPlansState> {
	final ActiveUserFunction _activeUser;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  CaregiverPlansCubit(this._activeUser) : super(CaregiverPlansInitial());

  loadCaregiverPlans() async {
    if (!(state is CaregiverPlansInitial)) return;

    var getDescription = (Plan plan) => _repeatabilityService.buildPlanDescription(plan.repeatability);
    var caregiverId = _activeUser().id;
    var plans = await _dataRepository.getPlans(caregiverId: caregiverId, activeOnly: false);

    List<UIPlan> uiPlans = [];
    for(int i=0;i<plans.length;i++) {
				uiPlans.add(UIPlan.fromDBModel(plans[i], getDescription(plans[i])));
		}
		emit(CaregiverPlansLoadSuccess(uiPlans));
  }
}
