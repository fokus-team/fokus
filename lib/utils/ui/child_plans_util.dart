
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';

import 'package:fokus/logic/common/timer/timer_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/navigation/plan_instance_params.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/chips/timer_chip.dart';
import 'package:fokus/widgets/segment.dart';

final String _plansKey = 'plans';

List<Widget> buildChildPlanSegments(List<UIPlanInstance> plans, BuildContext context) {
	var activePlan = plans.firstWhere((plan) => plan.state == PlanInstanceState.active, orElse: () => null);
	var otherPlans = plans.where((plan) => (activePlan == null || plan.id != activePlan.id) && plan.state != PlanInstanceState.completed).toList();
	var completedPlans = plans.where((plan) => plan.state == PlanInstanceState.completed).toList();

	return [
		if(activePlan != null)
			isInProgress(activePlan.duration) ?
			BlocProvider<TimerCubit>(
				create: (_) => TimerCubit.up(activePlan.elapsedActiveTime)..startTimer(),
				child: _getPlansSegment(
					context: context,
					plans: [activePlan],
					title: '$_plansKey.inProgress',
					displayTimer: true
				),
			) :
			_getPlansSegment(
				context: context,
				plans: [activePlan],
				title: '$_plansKey.inProgress',
			),
		if (otherPlans.isNotEmpty || plans.isEmpty)
			_getPlansSegment(
				context: context,
				plans: otherPlans,
				title: '$_plansKey.' + (activePlan == null ? 'todaysPlans' : 'remainingTodaysPlans'),
				noElementsMessage: '$_plansKey.noPlans'
			),
		if (completedPlans.isNotEmpty)
			_getPlansSegment(
				context: context,
				plans: completedPlans,
				title: '$_plansKey.completedPlans'
			),
	];
}

Segment _getPlansSegment({BuildContext context, List<UIPlanInstance> plans, String title, String noElementsMessage, bool displayTimer = false}) {
	var userRole = BlocProvider.of<AuthenticationBloc>(context).state.user?.role;
	return Segment(
		title: title,
		noElementsMessage: noElementsMessage,
		elements: <Widget>[
			for (var plan in plans)
				ItemCard(
					isActive: plan.state != PlanInstanceState.completed,
					title: plan.name,
					subtitle: plan.description(context),
					progressPercentage: (plan.state.inProgress || plan.state.ended) ? plan.completedTaskCount / plan.taskCount : null,
					chips: _getTaskChipForPlan(context, plan, displayTimer),
					onTapped: () => Navigator.of(context).pushNamed(AppPage.planInstanceDetails.name, arguments: PlanInstanceParams(planInstance: plan, actions: userRole == UserRole.child))
				)
		],
	);
}

List<Widget> _getTaskChipForPlan(BuildContext context, UIPlanInstance plan, bool displayTimer) {
	List<Widget> chips = [];
	var taskDescriptionKey = '$_plansKey.' + (plan.completedTaskCount > 0 ? 'taskProgress' : 'noTaskCompleted');
	if (displayTimer) chips.add(TimerChip(color: AppColors.childButtonColor));
	else if(plan.duration != null && plan.duration.isNotEmpty && !isInProgress(plan.duration))
		chips.add(AttributeChip.withIcon(
			icon: Icons.timer,
			color: Colors.orange,
			content: formatDuration(sumDurations(plan.duration))
		));
	if (!plan.state.inProgress)
		chips.add(AttributeChip.withIcon(
			icon: Icons.description,
			color: AppColors.mainBackgroundColor,
			content: AppLocales.of(context).translate('$_plansKey.tasks', {'NUM_TASKS': plan.taskCount})
		));
	else chips.add(AttributeChip.withIcon(
		icon: Icons.description,
		color: Colors.lightGreen,
		content: AppLocales.of(context).translate(taskDescriptionKey, {'NUM_TASKS': plan.completedTaskCount, 'NUM_ALL_TASKS': plan.taskCount})
	));
	return chips;
}
