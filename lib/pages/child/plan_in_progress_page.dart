import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/segment.dart';

class PlanInProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					CubitBuilder<ChildPlansCubit, ChildPlansState>(
						cubit: CubitProvider.of<ChildPlansCubit>(context),
						builder: (context, state) {
							if (state is ChildPlansInitial)
								CubitProvider.of<ChildPlansCubit>(context).loadChildPlansForToday();
							else if (state is ChildPlansLoadSuccess)
								return AppSegments(segments: _buildPanelSegments(state));
							return Expanded(child: Center(child: CircularProgressIndicator()));
						}
						)
				],
				)
			);
  }

	List<Segment> _buildPanelSegments(ChildPlansLoadSuccess state) {
		var mandatoryTasks = state.plans.where((plan) => (activePlan == null || plan.id != activePlan.id) && plan.state != PlanInstanceState.completed).toList();
		var additionalTasks = state.plans.where((plan) => (activePlan == null || plan.id != activePlan.id) && plan.state != PlanInstanceState.completed).toList();

		return [
			if(mandatoryTasks.isNotEmpty)
				_getTasksSegment(
					plans: [activePlan],
					icon: Icons.launch,
					color: AppColors.childActionColor,
					title: '$_pageKey.content.inProgress'
					),
			if (additionalTasks.isNotEmpty)
				_getTasksSegment(
					plans: otherPlans,
					icon: Icons.play_arrow,
					color: AppColors.childButtonColor,
					title: '$_pageKey.content.' + (activePlan == null ? 'todaysPlans' : 'remainingTodaysPlans'),
					noElementsMessage: '$_pageKey.content.noPlans'
					)
		];
	}

	Segment _getPlansSegment({List<UIPlanInstance> plans, IconData icon, Color color, String title, String noElementsMessage}) {
		return Segment(
			title: title,
			noElementsMessage: noElementsMessage,
			elements: <Widget>[
				for (var plan in plans)
					ItemCard(
						actionButton: ItemCardActionButton(
							icon: icon,
							color: color,
							disabled: plan.state == PlanInstanceState.completed,
							onTapped: () => {log("startPlan")}
							),
						title: plan.name,
						subtitle: plan.description(context),
						isActive: plan.state != PlanInstanceState.completed,
						progressPercentage: _planInProgress(plan) ? plan.completedTaskCount / plan.taskCount : null,
						chips: <Widget>[_getTaskChipForPlan(plan)],
						)
			],
			);
	}

}

