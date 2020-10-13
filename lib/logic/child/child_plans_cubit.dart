import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/plan_instance_service.dart';

class ChildPlansCubit extends ReloadableCubit {

	final ActiveUserFunction _activeUser;
	final PlanInstanceService _planService = GetIt.I<PlanInstanceService>();

  ChildPlansCubit(this._activeUser, ModalRoute pageRoute) : super(pageRoute);

  void doLoadData() async => emit(ChildPlansLoadSuccess(await _planService.loadPlanInstances(_activeUser().id)));
}

class ChildPlansLoadSuccess extends DataLoadSuccess {
	final List<UIPlanInstance> plans;

	ChildPlansLoadSuccess(this.plans);

	@override
	List<Object> get props => [plans];
}
