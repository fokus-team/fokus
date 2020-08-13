import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';

part 'caregiver_panel_state.dart';

class CaregiverPanelCubit extends Cubit<CaregiverPanelState> {
	final ActiveUserCubit _activeUserCubit;
	final DataRepository _dbRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  CaregiverPanelCubit(this._activeUserCubit) : super(CaregiverPanelInitial());

  void loadPanelData() async {
  	if (!(state is CaregiverPanelInitial))
  		return;
	  emit(CaregiverPanelLoadInProgress());
	  var activeUser = (_activeUserCubit.state as ActiveUserPresent).user;
	  var children = await _dbRepository.getCaregiverChildren(activeUser.id);
	  List<UIChild> childList = [];
	  for (var child in children) {
		  var plans = await _repeatabilityService.getPlansByDate(child.id, Date.now(), activeOnly: false);
		  childList.add(UIChild.fromDBModel(child, todayPlanCount: plans.length, hasActivePlan: await _dbRepository.getActiveChildPlanInstance(child.id)));
	  }
	  emit(CaregiverPanelLoadSuccess(childList, await _dbRepository.getUserNames((activeUser as UICaregiver).friends)));
  }
}
