import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/logic/caregiver_plans_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/services/app_locales.dart';

import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverPlansPage extends StatefulWidget {
	@override
	_CaregiverPlansPageState createState() => new _CaregiverPlansPageState();
}

const String _pageKey = 'page.caregiverSection.plans';

class _CaregiverPlansPageState extends State<CaregiverPlansPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppHeader.normal(title: '$_pageKey.header.title', text: '$_pageKey.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.add, '$_pageKey.header.addPlan',
							() => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name)),
						HeaderActionButton.normal(Icons.calendar_today, '$_pageKey.header.calendar', 
							() => log("Kalendarz"), Colors.amber)
					]),
					LoadableBlocBuilder<CaregiverPlansCubit>(
						builder: (context, state) => AppSegments(segments: _buildPanelSegments(state, context))
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 1));
	}
}

List<Segment> _buildPanelSegments(CaregiverPlansLoadSuccess state, context) {
	var activePlans = state.plans.where((blueprint) => (blueprint.isActive)).toList();
	var deactivatedPlans = state.plans.where((blueprint) => (!blueprint.isActive)).toList();
	return [
		_getPlansSegment(
			plans: activePlans,
			title: '$_pageKey.content.addedActivePlansTitle',
			noElementsAction: deactivatedPlans.isEmpty ? RaisedButton(
				child: Text(AppLocales.of(context).translate('$_pageKey.header.addPlan'),
					style: Theme.of(context).textTheme.button),
				onPressed: () => {}
			) : SizedBox.shrink(),
			context: context
		),
		if (deactivatedPlans.isNotEmpty)
			_getPlansSegment(plans: deactivatedPlans, title: '$_pageKey.content.addedDeactivatedPlansTitle', context: context)
	];
}

Segment _getPlansSegment({List<UIPlan> plans, String title, String noElementsMessage, Widget noElementsAction, context}) {
	return Segment(
		title: title,
		noElementsMessage: '$_pageKey.content.noPlansAdded',
		noElementsAction: noElementsAction,
		elements: <Widget>[
			for (var plan in plans)
				ItemCard(
					title: plan.name,
					subtitle: plan.description(context),
					actionButton: ItemCardActionButton(
						color: Colors.teal, icon: Icons.keyboard_arrow_right, onTapped: () => {Navigator.of(context).pushNamed(AppPage.caregiverPlanDetails.name)}),
					chips: <Widget>[
						AttributeChip.withIcon(
							content: AppLocales.of(context).translate('$_pageKey.content.tasks', {'NUM_TASKS': plan.taskCount}),
							color: Colors.indigo,
							icon: Icons.layers
						)
					]
				)
		]
	);
}
