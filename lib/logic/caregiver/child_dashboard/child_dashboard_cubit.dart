import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
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
  void doLoadData() async {
	  await loadTab(_initialTab);
	  await loadTab((_initialTab + 1) % 3);
	  await loadTab((_initialTab + 2) % 3);
  }

  Future loadTab(int tabIndex) => _tabFunctions[tabIndex.clamp(0, 3)]();

	Future _loadPlansTab() async {
		var activeUser = _activeUser();
		var planInstances = (await _dataRepository.getPlanInstances(childIDs: [childId], fields: ['_id'])).map((plan) => plan.id).toList();
  	var data = await Future.wait([
		  _dataAggregator.loadPlanInstances(childId),
		  _dataRepository.countTaskInstances(planInstancesId: planInstances, isCompleted: true, state: TaskState.notEvaluated),
		  _dataRepository.countPlans(caregiverId: activeUser.id),
		  _dataRepository.getPlans(caregiverId: activeUser.id, fields: ['_id', 'name', 'assignedTo']),
	  ]);
  	var availablePlans = (data[3] as List<Plan>).map((plan) => UIPlan.fromDBModel(plan)).toList();
  	var tabState = ChildDashboardPlansTabState(childPlans: data[0], availablePlans: availablePlans, unratedTasks: (data[1] as int) > 0, noPlansAdded: (data[2] as int) == 0);
		emit(ChildDashboardState.from(_getPreviousState(), plansTab: tabState, child: await _loadChildProfile()));
	}

	Future _loadRewardsTab() async {
  	var tabState = ChildDashboardRewardsTabState();
		emit(ChildDashboardState.from(_getPreviousState(), rewardsTab: tabState, child: await _loadChildProfile()));
	}

	Future _loadAchievementsTab() async {
		var tabState = ChildDashboardAchievementsTabState();
		emit(ChildDashboardState.from(_getPreviousState(), achievementsTab: tabState, child: await _loadChildProfile()));
	}

	Future<UIChild> _loadChildProfile() => state is ChildDashboardState ? null : _dataAggregator.loadChild(childId);
	ChildDashboardState _getPreviousState() => state is ChildDashboardState ? state : null;
}
