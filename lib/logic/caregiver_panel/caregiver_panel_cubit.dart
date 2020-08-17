import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/user/user_role.dart';

part 'caregiver_panel_state.dart';

class CaregiverPanelCubit extends Cubit<CaregiverPanelState> {
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  CaregiverPanelCubit(this._activeUser) : super(CaregiverPanelInitial());

  void loadPanelData() async {
  	if (!(state is CaregiverPanelInitial))
  		return;
	  emit(CaregiverPanelLoadInProgress());
	  var activeUser = _activeUser();
	  var children = await _dataRepository.getUsers(connected: activeUser.id, role: UserRole.child);
	  List<UIChild> childList = [];
	  for (var child in children) {
		  var plans = await _repeatabilityService.getPlansByDate(child.id, Date.now(), activeOnly: false);
		  childList.add(UIChild.fromDBModel(child, todayPlanCount: plans.length, hasActivePlan: await _dataRepository.getActiveChildPlanInstance(child.id)));
	  }
	  emit(CaregiverPanelLoadSuccess(childList, await _dataRepository.getUserNames((activeUser as UICaregiver).friends)));
  }
}
