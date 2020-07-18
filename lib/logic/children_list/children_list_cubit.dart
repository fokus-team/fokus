import 'package:cubit/cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/model/ui/ui_child.dart';
import 'package:fokus/services/database/data_repository.dart';

part 'children_list_state.dart';

class ChildrenListCubit extends Cubit<ChildrenListState> {
	final ActiveUserCubit _activeUserCubit;
	final DataRepository _dbProvider = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  ChildrenListCubit(this._activeUserCubit) : super(ChildrenListInitial());
  
  void loadCaregiverChildren() async {
	  emit(ChildrenListLoadInProgress());
	  var userId = (_activeUserCubit.state as ActiveUserPresent).user.id;
	  var children = await _dbProvider.getCaregiverChildren(userId);
	  List<UIChild> stateList = [];
	  for (var child in children) {
	  	var plans = await _repeatabilityService.getChildPlansByDate(child.id, Date.now(), activeOnly: false);
		  stateList.add(UIChild.fromDBModel(child, todayPlanCount: plans.length, hasActivePlan: await _dbProvider.childActivePlanInstanceExists(child.id)));
	  }
	  emit(ChildrenListLoadSuccess(stateList));
  }
}
