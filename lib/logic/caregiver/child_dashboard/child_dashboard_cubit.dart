import 'package:flutter/widgets.dart';

import '../../../model/db/user/child.dart';
import '../../../model/navigation/child_dashboard_params.dart';
import '../../../model/ui/child_card_model.dart';
import '../../common/stateful/stateful_cubit.dart';
import 'dashboard_achievements_cubit.dart';
import 'dashboard_plans_cubit.dart';
import 'dashboard_rewards_cubit.dart';

class ChildDashboardCubit extends StatefulCubit {
	final ChildCardModel _childCard;

	final int _initialTab;
	
	late List<StatefulCubit> _tabCubits;
	final DashboardPlansCubit _plansCubit;
	final DashboardRewardsCubit _rewardsCubit;
	final DashboardAchievementsCubit _achievementsCubit;

  ChildDashboardCubit(ChildDashboardParams args, ModalRoute pageRoute, this._plansCubit, this._rewardsCubit, this._achievementsCubit) :
			_initialTab = args.tab ?? 0, _childCard = args.childCard, super(pageRoute) {
	  _tabCubits = [_plansCubit, _rewardsCubit, _achievementsCubit];
  }

  @override
  Future doLoadData() async {
	  _plansCubit.child = _childCard.child;
	  _rewardsCubit.child = _childCard.child;
	  _achievementsCubit.child = _childCard.child;
	  loadTab((_initialTab + 1) % 3);
	  loadTab((_initialTab + 2) % 3);
	  await loadTab(_initialTab);
	  emit(ChildDashboardState(childCard: _childCard));
  }

  Future loadTab(int tabIndex) {
  	var cubit = _tabCubits[tabIndex.clamp(0, 3)];
  	if (cubit.state.isNotLoaded)
      return cubit.loadData();
  	return Future.value();
  }

	Future onNameDialogClosed(Future<String?> result) async {
  	var value = await result;
		if (value == null)
			return;
		var childCard = (state as ChildDashboardState).childCard;
		emit(ChildDashboardState(childCard: childCard.copyWith(child: Child.copyFrom(childCard.child, name: value))));
	}
}

class ChildDashboardState extends StatefulState {
	final ChildCardModel childCard;

	ChildDashboardState({required this.childCard}) : super.loaded();

	@override
	List<Object?> get props => super.props..add(childCard);
}
