import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/model/ui/ui_child.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/widgets/app_navigation_bar.dart';

import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/logic/child_plans/child_plans_cubit.dart';

import 'package:fokus/widgets/app_header.dart';
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
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ChildCustomHeader(),
          CubitBuilder<ChildPlansCubit, ChildPlansState>(
            cubit: CubitProvider.of<ChildPlansCubit>(context),
            builder: (context, state) {
              if (state is ChildPlansInitial)
                CubitProvider.of<ChildPlansCubit>(context)
                    .loadChildPlansForToday();
              else if (state is ChildPlansLoadSuccess)
                return AppSegments(segments: _buildPanelSegments(state));
              return Expanded(
                  child: Center(child: CircularProgressIndicator()));
            },
          ),
          Row(
						mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[RoundedButton(
              iconData: Icons.calendar_today,
              text:
                  '${AppLocales.of(context).translate("page.childSection.panel.content.futurePlans")} ',
              color: AppColors.childFuturePlansButton,
            )],
          )
        ]),
        bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0));
  }

  List<Segment> _buildPanelSegments(ChildPlansLoadSuccess state) {
    var user =
        ((CubitProvider.of<ActiveUserCubit>(context).state as ActiveUserPresent)
            .user) as UIChild;
    return [
      if (user.hasActivePlan)
        Segment(title: '$_pageKey.content.inProgress', elements: <Widget>[
          for (var plan in state.plans)
            ItemCard(
                actionButton: ItemCardActionButton(
                    icon: Icons.launch,
                    color: AppColors.childOpenActivePlanColor,
                    onTapped: () => {log("startPlan")}),
                title: plan.name,
                subtitle: plan.description(context),
                chips: <Widget>[
                  AttributeChip.withIcon(
                      icon: Icons.description,
                      color: AppColors.childPlanTaskCountChipColor,
                      content:
                          ' ${AppLocales.of(context).translate("page.childSection.panel.content.tasks", {
                        'NUM_TASKS': plan.taskCount
                      })}')
                ])
        ]),
      Segment(
          title: '$_pageKey.content.todaysPlans',
          noElementsMessage: '$_pageKey.content.noPlans',
          elements: <Widget>[
            for (var plan in state.plans)
              ItemCard(
                  actionButton: ItemCardActionButton(
                      icon: Icons.play_arrow,
                      color: AppColors.childOpenNewPlanColor,
                      onTapped: () => {log("startPlan")}),
                  title: plan.name,
                  subtitle: plan.description(context),
                  chips: <Widget>[
                    AttributeChip.withIcon(
                        icon: Icons.description,
                        color: AppColors.childPlanTaskCountChipColor,
                        content:
                            ' ${AppLocales.of(context).translate("page.childSection.panel.content.tasks", {
                          'NUM_TASKS': plan.taskCount
                        })}')
                  ])
          ]),
    ];
  }

}
