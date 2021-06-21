import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../model/ui/plan/ui_plan_instance.dart';
import '../../services/model_helpers/ui_data_aggregator.dart';
import '../common/cubit_base.dart';

class ChildPanelCubit extends CubitBase<ChildPlansData> {
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();

  ChildPanelCubit(ModalRoute pageRoute) : super(pageRoute);

  @override
  Future reload(_) => load(body: () async {
  	if (activeUser == null) return null;
    return ChildPlansData(await _dataAggregator.loadTodaysPlanInstances(childId: activeUser!.id!));
  });
}

class ChildPlansData extends Equatable {
	final List<UIPlanInstance> plans;

	ChildPlansData(this.plans);

	@override
	List<Object?> get props => [plans];
}
