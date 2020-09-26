import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';

import 'package:fokus/logic/child_plans_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/chips/timer_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/buttons/rounded_button.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';


class ChildPanelPage extends StatefulWidget {
  @override
  _ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	static const String _pageKey = 'page.childSection.panel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
	      crossAxisAlignment: CrossAxisAlignment.start,
	      children: [
	        ChildCustomHeader(),
		      LoadableBlocBuilder<ChildPlansCubit>(
				    builder: (context, state) => AppSegments(segments: _buildPanelSegments(state)),
						wrapWithExpanded: true,
		      )
	      ]
      ),
      bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0)
    );
  }

  List<Widget> _buildPanelSegments(ChildPlansLoadSuccess state) {
		UIChild currentUser = context.bloc<AuthenticationBloc>().state.user;
  	var activePlan = state.plans.firstWhere((plan) => plan.state == PlanInstanceState.active, orElse: () => null);
  	var otherPlans = state.plans.where((plan) => (activePlan == null || plan.id != activePlan.id) && plan.state != PlanInstanceState.completed).toList();
  	var completedPlans = state.plans.where((plan) => plan.state == PlanInstanceState.completed).toList();

    return [
			if(activePlan != null)
				isInProgress(activePlan.duration) ?
					BlocProvider<TimerCubit>(
						create: (_) => TimerCubit.up(activePlan.elapsedActiveTime)..startTimer(),
						child: _getPlansSegment(
							plans: [activePlan],
							icon: Icons.launch,
							color: AppColors.childActionColor,
							title: '$_pageKey.content.inProgress',
							displayTimer: true
						),
					) :
					_getPlansSegment(
						plans: [activePlan],
						icon: Icons.launch,
						color: AppColors.childActionColor,
						title: '$_pageKey.content.inProgress',
					),
	    if (otherPlans.isNotEmpty || state.plans.isEmpty)
		    _getPlansSegment(
			    plans: otherPlans,
			    icon: Icons.play_arrow,
			    color: AppColors.childButtonColor,
			    title: '$_pageKey.content.' + (activePlan == null ? 'todaysPlans' : 'remainingTodaysPlans'),
			    noElementsMessage: '$_pageKey.content.noPlans'
		    ),
	    if (completedPlans.isNotEmpty)
		    _getPlansSegment(
			    plans: completedPlans,
			    icon: Icons.check,
			    color: AppColors.childBackgroundColor,
			    title: '$_pageKey.content.completedPlans'
		    ),
				Row(
					mainAxisAlignment: MainAxisAlignment.end,
					children: <Widget>[
						RoundedButton(
							icon: Icons.calendar_today,
							text: AppLocales.of(context).translate('$_pageKey.content.futurePlans'),
							color: AppColors.childButtonColor,
							onPressed: () => Navigator.of(context).pushNamed(AppPage.childCalendar.name, arguments: currentUser.id)
						)
					]
				)
    ];
  }

  Segment _getPlansSegment({List<UIPlanInstance> plans, IconData icon, Color color, String title, String noElementsMessage, bool displayTimer = false}) {
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
						  onTapped: () => Navigator.of(context).pushNamed(AppPage.childPlanInProgress.name, arguments: plan)
						),
					  title: plan.name,
					  subtitle: plan.description(context),
					  isActive: plan.state != PlanInstanceState.completed,
					  progressPercentage: plan.state.inProgress ? plan.completedTaskCount / plan.taskCount : null,
					  chips: _getTaskChipForPlan(plan, displayTimer)
					  ,
				  )
		  ],
	  );
  }

  List<Widget> _getTaskChipForPlan(UIPlanInstance plan, bool displayTimer) {
  	List<Widget> chips = [];
		var taskDescriptionKey = '$_pageKey.content.' + (plan.completedTaskCount > 0 ? 'taskProgress' : 'noTaskCompleted');
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
				content: AppLocales.of(context).translate('$_pageKey.content.tasks', {'NUM_TASKS': plan.taskCount})
			));
		else chips.add(AttributeChip.withIcon(
			icon: Icons.description,
			color: Colors.lightGreen,
			content: AppLocales.of(context).translate(taskDescriptionKey, {'NUM_TASKS': plan.completedTaskCount, 'NUM_ALL_TASKS': plan.taskCount})
		));
	  return chips;
  }
}
