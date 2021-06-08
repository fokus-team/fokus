import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/ui_data_aggregator.dart';

class ChildPanelCubit extends StatefulCubit {
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();

  ChildPanelCubit(ModalRoute pageRoute) : super(pageRoute);

  Future doLoadData() async => emit(ChildPlansState(await _dataAggregator.loadTodaysPlanInstances(childId: activeUser!.id!)));
}

class ChildPlansState extends StatefulState {
	final List<UIPlanInstance> plans;

	ChildPlansState(this.plans) : super.loaded();

	@override
	List<Object?> get props => super.props..add(plans);
}
