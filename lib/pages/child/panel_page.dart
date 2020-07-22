import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/logic/child_plans/child_plans_cubit.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/attribute_chip.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/rounded_button.dart';
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
	        CubitBuilder<ChildPlansCubit, ChildPlansState>(
	          cubit: CubitProvider.of<ChildPlansCubit>(context),
	          builder: (context, state) {
	            if (state is ChildPlansInitial)
	              CubitProvider.of<ChildPlansCubit>(context).loadChildPlansForToday();
	            else if (state is ChildPlansLoadSuccess)
	              return AppSegments(segments: _buildPanelSegments(state));
	            return Expanded(child: Center(child: CircularProgressIndicator()));
	          },
	        ),
	        Row(
						mainAxisAlignment: MainAxisAlignment.end,
	          children: <Widget>[
	            RoundedButton(
		            iconData: Icons.calendar_today,
		            text: '${AppLocales.of(context).translate("$_pageKey.content.futurePlans")} ',
		            color: AppColors.childButtonColor,
		          ),
	          ],
	        )
	      ],
      ),
      bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0)
    );
  }

  List<Segment> _buildPanelSegments(ChildPlansLoadSuccess state) {
    return [
			if(state.activePlan != null)
        Segment(title: '$_pageKey.content.inProgress', elements: <Widget>[
          ItemCard(
            actionButton: ItemCardActionButton(
              icon: Icons.launch,
              color: AppColors.childActionColor,
              onTapped: () => {log("startPlan")},
            ),
            title: state.activePlan.name,
            subtitle: state.activePlan.description(context),
            isActive: true,
            //TODO: add progress from DB
            progressPercentage: 0.4,
            chips: <Widget>[
              AttributeChip.withIcon(
                icon: Icons.description,
                color: AppColors.mainBackgroundColor,
                content: ' ${AppLocales.of(context).translate("$_pageKey.content.tasks", {'NUM_TASKS': state.activePlan.taskCount})}'
              )
            ],
          )
        ],
      ),
      Segment(
        title: '$_pageKey.content.' + (state.activePlan == null ? 'todaysPlans' : 'remainingTodaysPlans'),
        noElementsMessage: '$_pageKey.content.' + (state.activePlan == null ? 'noPlans' : 'allPlansCompleted'),
        elements: <Widget>[
          for (var plan in state.plans)
            ItemCard(
              actionButton: ItemCardActionButton(
                icon: Icons.play_arrow,
                color: AppColors.childButtonColor,
                onTapped: () => {log("startPlan")}),
              title: plan.name,
              subtitle: plan.description(context),
              chips: <Widget>[
                AttributeChip.withIcon(
                  icon: Icons.description,
                  color: AppColors.mainBackgroundColor,
                  content: ' ${AppLocales.of(context).translate("$_pageKey.content.tasks", {'NUM_TASKS': plan.taskCount})}'
                )
              ],
            )
        ],
      ),
    ];
  }
}
