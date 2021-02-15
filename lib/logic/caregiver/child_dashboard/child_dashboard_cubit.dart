import 'package:flutter/widgets.dart';
import 'package:fokus/logic/caregiver/child_dashboard/dashboard_achievements_cubit.dart';
import 'package:fokus/logic/caregiver/child_dashboard/dashboard_plans_cubit.dart';
import 'package:fokus/logic/caregiver/child_dashboard/dashboard_rewards_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/ui_data_aggregator.dart';

class ChildDashboardCubit extends StatefulCubit {
	final ObjectId childId;

	int _initialTab;
	
	List<StatefulCubit> _tabCubits;
	DashboardPlansCubit _plansCubit;
	DashboardRewardsCubit _rewardsCubit;
	DashboardAchievementsCubit _achievementsCubit;
	
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();

  ChildDashboardCubit(Map<String, dynamic> args, ModalRoute pageRoute, this._plansCubit, this._rewardsCubit, this._achievementsCubit) :
			_initialTab = args['tab'] ?? 0, childId = (args['child'] as UIChild).id, super(pageRoute) {
	  _tabCubits = [_plansCubit, _rewardsCubit, _achievementsCubit];
  }

  @override
  Future doLoadData() async {
  	var child = await _dataAggregator.loadChild(childId);
	  _plansCubit.child = child;
	  _rewardsCubit.child = child;
	  _achievementsCubit.child = child;
	  await loadTab(_initialTab);
	  await loadTab((_initialTab + 1) % 3);
	  await loadTab((_initialTab + 2) % 3);
	  emit(ChildDashboardState(child: child));
  }

  Future loadTab(int tabIndex) => _tabCubits[tabIndex.clamp(0, 3)].loadData();

	Future onNameDialogClosed(Future<String> result) async {
  	var value = await result;
		if (value == null)
			return;
		emit(ChildDashboardState(child: UIChild.from((state as ChildDashboardState).child, name: value)));
	}
}

class ChildDashboardState extends StatefulState {
	final UIChild child;

	ChildDashboardState({this.child}) : super.loaded();

	@override
	List<Object> get props => super.props..addAll([child]);
}
