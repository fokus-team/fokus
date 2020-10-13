import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/services/plan_instance_service.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';

part 'child_dashboard_state.dart';

class ChildDashboardCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	int _initialTab;
	List<Future Function()> _tabFunctions;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanInstanceService _planService = GetIt.I<PlanInstanceService>();

  ChildDashboardCubit(Map<String, dynamic> args, this._activeUser, ModalRoute pageRoute) :
			_initialTab = args != null ? args['tab'] ?? 0 : 0, super(pageRoute) {
	  _tabFunctions = [_loadPlansTab, _loadRewardsTab, _loadAchievementsTab];
  }

  @override
  void doLoadData() => loadTab(_initialTab);

  Future loadTab(int tabIndex) {
  	_initialTab = tabIndex.clamp(0, 3);
    return _tabFunctions[tabIndex]();
  }

	Future _loadPlansTab() async {
  	var plansTabState = ChildDashboardPlansTabState(await _planService.loadPlanInstances(_activeUser().connections.first));
		emit(ChildDashboardState(initialTab: _initialTab, plansTab: plansTabState));
	}

	Future _loadRewardsTab() async {
		emit(ChildDashboardState(initialTab: _initialTab));
	}

	Future _loadAchievementsTab() async {
		emit(ChildDashboardState(initialTab: _initialTab));
	}
}
