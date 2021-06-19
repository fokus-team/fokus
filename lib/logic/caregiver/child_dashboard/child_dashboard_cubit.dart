import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../../model/db/user/child.dart';
import '../../../model/navigation/child_dashboard_params.dart';
import '../../../model/ui/child_card_model.dart';
import '../../common/stateful/stateful_cubit.dart';
import 'dashboard_achievements_cubit.dart';
import 'dashboard_plans_cubit.dart';
import 'dashboard_rewards_cubit.dart';

class ChildDashboardCubit extends StatefulCubit<ChildDashboardData> {
	final ChildCardModel _childCard;

	final int _initialTab;
	
	final List<StatefulCubit> _tabCubits;
	final DashboardPlansCubit _plansCubit;
	final DashboardRewardsCubit _rewardsCubit;
	final DashboardAchievementsCubit _achievementsCubit;

  ChildDashboardCubit(ChildDashboardParams args, ModalRoute pageRoute, this._plansCubit, this._rewardsCubit, this._achievementsCubit) :
			  _initialTab = args.tab ?? 0,
			  _childCard = args.childCard,
			  _tabCubits = [_plansCubit, _rewardsCubit, _achievementsCubit],
			  super(pageRoute, options: [StatefulOption.resetSubmissionState]);

  @override
  Future load() => doLoad(body: () async {
	  _plansCubit.child = _childCard.child;
	  _rewardsCubit.child = _childCard.child;
	  _achievementsCubit.child = _childCard.child;
	  loadTab((_initialTab + 1) % 3);
	  loadTab((_initialTab + 2) % 3);
	  await loadTab(_initialTab);
	  return ChildDashboardData(childCard: _childCard);
  });

  Future loadTab(int tabIndex) {
  	var cubit = _tabCubits[tabIndex.clamp(0, 3)];
  	return cubit.load();
  }

	Future onNameDialogClosed(Future<String?> result) => submit(body: () async {
  	var value = await result;
		if (value == null)
			return null;
		var childCard = state.data!.childCard;
		return ChildDashboardData(childCard: childCard.copyWith(child: Child.copyFrom(childCard.child, name: value)));
	});
}

class ChildDashboardData extends Equatable {
	final ChildCardModel childCard;

	ChildDashboardData({required this.childCard});

	@override
	List<Object?> get props => [childCard];
}
