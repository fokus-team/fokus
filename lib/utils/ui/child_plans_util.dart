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
import 'package:collection/collection.dart';

final String _plansKey = 'plans';

List<Widget> buildChildPlanSegments(List<UIPlanInstance?> plans, BuildContext context) {
	UIPlanInstance? activePlan = plans.firstWhereOrNull((plan) => plan != null && plan.instance.state == PlanInstanceState.active);
	List<UIPlanInstance?> otherPlans = plans.where((plan) => (activePlan == null || (plan != null && plan.instance.id != activePlan.instance.id))
			&& (plan != null && plan.instance.state != PlanInstanceState.completed)).toList();
	var completedPlans = plans.where((plan) => plan!= null && plan.instance.state == PlanInstanceState.completed).toList();

	return [
		if(activePlan != null)
			isInProgress(activePlan.instance.duration) ?
			BlocProvider<TimerCubit>(
				create: (_) => TimerCubit.up(activePlan.elapsedActiveTime!)..startTimer(),
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

Segment _getPlansSegment({required BuildContext context, required List<UIPlanInstance?> plans, required String title, String? noElementsMessage, bool displayTimer = false}) {
	var userRole = BlocProvider.of<AuthenticationBloc>(context).state.user?.role;
	return Segment(
		title: title,
		noElementsMessage: noElementsMessage,
		elements: <Widget>[
			for (var uiPlan in plans)
				ItemCard(
					isActive: uiPlan!.instance.state != PlanInstanceState.completed,
					title: uiPlan.plan.name!,
					subtitle: uiPlan.description!,
					progressPercentage: (uiPlan.instance.state!.inProgress || uiPlan.instance.state!.ended) ? uiPlan.completedTaskCount! / uiPlan.instance.tasks!.length : null,
					chips: _getTaskChipForPlan(context, uiPlan, displayTimer),
					onTapped: () => Navigator.of(context).pushNamed(AppPage.planInstanceDetails.name, arguments: PlanInstanceParams(planInstance: uiPlan, actions: userRole == UserRole.child))
				)
		],
	);
}

List<Widget> _getTaskChipForPlan(BuildContext context, UIPlanInstance plan, bool displayTimer) {
	List<Widget> chips = [];
	var taskDescriptionKey = '$_plansKey.' + (plan.completedTaskCount! > 0 ? 'taskProgress' : 'noTaskCompleted');
	if (displayTimer) chips.add(TimerChip(color: AppColors.childButtonColor));
	else if(plan.instance.duration != null && plan.instance.duration!.isNotEmpty && !isInProgress(plan.instance.duration))
		chips.add(AttributeChip.withIcon(
			icon: Icons.timer,
			color: Colors.orange,
			content: formatDuration(sumDurations(plan.instance.duration))
		));
	if (!plan.instance.state!.inProgress)
		chips.add(AttributeChip.withIcon(
			icon: Icons.description,
			color: AppColors.mainBackgroundColor,
			content: AppLocales.of(context).translate('$_plansKey.tasks', {'NUM_TASKS': plan.instance.tasks!.length})
		));
	else chips.add(AttributeChip.withIcon(
		icon: Icons.description,
		color: Colors.lightGreen,
		content: AppLocales.of(context).translate(taskDescriptionKey, {'NUM_TASKS': plan.completedTaskCount!, 'NUM_ALL_TASKS': plan.instance.tasks!.length})
	));
	return chips;
}
