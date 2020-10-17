import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/ui_data_aggregator.dart';

class ChildPanelCubit extends ReloadableCubit {

	final ActiveUserFunction _activeUser;
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();

  ChildPanelCubit(this._activeUser, ModalRoute pageRoute) : super(pageRoute);

  void doLoadData() async => emit(ChildPlansLoadSuccess(await _dataAggregator.loadPlanInstances(childId: _activeUser().id)));
}

class ChildPlansLoadSuccess extends DataLoadSuccess {
	final List<UIPlanInstance> plans;

	ChildPlansLoadSuccess(this.plans);

	@override
	List<Object> get props => [plans];
}
