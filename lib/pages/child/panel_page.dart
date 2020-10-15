import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/child/child_plans_cubit.dart';
import 'package:fokus/logic/common/timer/timer_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/chips/timer_chip.dart';
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
		UIChild currentUser = context.bloc<AuthenticationBloc>().state.user;
    return Scaffold(
      body: Column(
	      crossAxisAlignment: CrossAxisAlignment.start,
				verticalDirection: VerticalDirection.up,
	      children: [
		      LoadableBlocBuilder<ChildPlansCubit>(
				    builder: (context, state) => AppSegments(segments: _buildPanelSegments(state)),
						wrapWithExpanded: true,
		      ),
	        CustomChildAppBar()
	      ]
      ),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => Navigator.of(context).pushNamed(AppPage.childCalendar.name, arguments: currentUser.id),
				label: Text(AppLocales.of(context).translate('$_pageKey.content.futurePlans')),
				icon: Icon(Icons.calendar_today),
				backgroundColor: AppColors.childButtonColor,
				elevation: 4.0
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0)
    );
  }

  List<Widget> _buildPanelSegments(ChildPlansLoadSuccess state) {
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
							title: '$_pageKey.content.inProgress',
							displayTimer: true
						),
					) :
					_getPlansSegment(
						plans: [activePlan],
						title: '$_pageKey.content.inProgress',
					),
	    if (otherPlans.isNotEmpty || state.plans.isEmpty)
		    _getPlansSegment(
			    plans: otherPlans,
			    title: '$_pageKey.content.' + (activePlan == null ? 'todaysPlans' : 'remainingTodaysPlans'),
			    noElementsMessage: '$_pageKey.content.noPlans'
		    ),
	    if (completedPlans.isNotEmpty)
		    _getPlansSegment(
			    plans: completedPlans,
			    title: '$_pageKey.content.completedPlans'
		    )
    ];
  }

  Segment _getPlansSegment({List<UIPlanInstance> plans, String title, String noElementsMessage, bool displayTimer = false}) {
  	return Segment(
		  title: title,
		  noElementsMessage: noElementsMessage,
		  elements: <Widget>[
			  for (var plan in plans)
				  ItemCard(
						isActive: plan.state != PlanInstanceState.completed,
					  title: plan.name,
					  subtitle: plan.description(context),
					  progressPercentage: plan.state.inProgress ? plan.completedTaskCount / plan.taskCount : null,
					  chips: _getTaskChipForPlan(plan, displayTimer),
						onTapped: () => Navigator.of(context).pushNamed(AppPage.planInstanceDetails.name, arguments: plan)
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
