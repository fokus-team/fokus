import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' hide Action;
import 'package:reloadable_bloc/reloadable_bloc.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../../../model/db/user/child.dart';
import '../../../model/navigation/child_dashboard_params.dart';
import '../../../model/ui/child_card_model.dart';
import '../../common/cubit_base.dart';
import 'dashboard_achievements_cubit.dart';
import 'dashboard_plans_cubit.dart';
import 'dashboard_rewards_cubit.dart';

class ChildDashboardCubit extends CubitBase<ChildDashboardData> {
	final ChildCardModel _childCard;

	final int _initialTab;
	
	final List<CubitBase> _tabCubits;
	final DashboardPlansCubit _plansCubit;
	final DashboardRewardsCubit _rewardsCubit;
	final DashboardAchievementsCubit _achievementsCubit;

  ChildDashboardCubit(ChildDashboardParams args, ModalRoute pageRoute, this._plansCubit, this._rewardsCubit, this._achievementsCubit) :
			  _initialTab = args.tab ?? 0,
			  _childCard = args.childCard,
			  _tabCubits = [_plansCubit, _rewardsCubit, _achievementsCubit],
			  super(pageRoute);

  @override
  Future reload(ReloadableReason reason) => load(body: () async {
	  _plansCubit.child = _childCard.child;
	  _rewardsCubit.child = _childCard.child;
	  _achievementsCubit.child = _childCard.child;
	  loadTab((_initialTab + 1) % 3, reason);
	  loadTab((_initialTab + 2) % 3, reason);
	  await loadTab(_initialTab, reason);
	  return Action.finish(ChildDashboardData(childCard: _childCard));
  });

  Future loadTab(int tabIndex, ReloadableReason reason) {
  	var cubit = _tabCubits[tabIndex.clamp(0, 3)];
  	return cubit.reload(reason);
  }

	Future onNameDialogClosed(Future<String?> result) => submit(body: () async {
  	var value = await result;
		if (value == null)
			return Action.cancel();
		var childCard = state.data!.childCard;
		return Action.finish(ChildDashboardData(childCard: childCard.copyWith(child: Child.copyFrom(childCard.child, name: value))));
	});
}

class ChildDashboardData extends Equatable {
	final ChildCardModel childCard;

	ChildDashboardData({required this.childCard});

	@override
	List<Object?> get props => [childCard];
}
