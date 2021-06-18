import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../model/ui/plan/ui_plan_instance.dart';
import '../../services/model_helpers/ui_data_aggregator.dart';
import '../common/stateful/stateful_cubit.dart';

class ChildPanelCubit extends StatefulCubit {
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();

  ChildPanelCubit(ModalRoute pageRoute) : super(pageRoute);

  @override
  Future doLoadData() async => emit(ChildPlansState(await _dataAggregator.loadTodaysPlanInstances(childId: activeUser!.id!)));
}

class ChildPlansState extends StatefulState {
	final List<UIPlanInstance> plans;

	ChildPlansState(this.plans) : super.loaded();

	@override
	List<Object?> get props => super.props..add(plans);
}
