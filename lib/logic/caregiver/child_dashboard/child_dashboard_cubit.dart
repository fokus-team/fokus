import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/services/ui_data_aggregator.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'child_dashboard_state.dart';

class ChildDashboardCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	final ObjectId childId;

	int _initialTab;
	List<Future Function()> _tabFunctions;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();

  ChildDashboardCubit(Map<String, dynamic> args, this._activeUser, ModalRoute pageRoute) :
			_initialTab = args['tab'] ?? 0, childId = (args['child'] as UIChild).id, super(pageRoute) {
	  _tabFunctions = [_loadPlansTab, _loadRewardsTab, _loadAchievementsTab];
  }

  @override
  void doLoadData() => loadTab(_initialTab);

  Future loadTab(int tabIndex) {
  	_initialTab = tabIndex.clamp(0, 3);
    return _tabFunctions[tabIndex]();
  }

	Future _loadPlansTab() async {
  	var data = await Future.wait([
		  _dataAggregator.loadPlanInstances(childId),
		  _dataAggregator.loadChild(childId),
	  ]);
  	var plansTabState = ChildDashboardPlansTabState(data[0]);
		emit(ChildDashboardState(plansTab: plansTabState, child: data[1]));
	}

	Future _loadRewardsTab() async {
		emit(ChildDashboardState());
	}

	Future _loadAchievementsTab() async {
		emit(ChildDashboardState());
	}
}
