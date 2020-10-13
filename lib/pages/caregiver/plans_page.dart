import 'package:flutter/material.dart';
import 'package:fokus/logic/caregiver_plans_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
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
			appBar: CustomAppBar(type: CustomAppBarType.normal, title: '$_pageKey.header.title', subtitle: '$_pageKey.header.pageHint', icon: Icons.description),
			body: LoadableBlocBuilder<CaregiverPlansCubit>(
				builder: (context, state) => AppSegments(segments: _buildPanelSegments(state, context), fullBody: true),
			),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => Navigator.of(context).pushNamed(AppPage.caregiverCalendar.name),
				label: Text(AppLocales.of(context).translate('$_pageKey.header.calendar')),
				icon: Icon(Icons.calendar_today),
				backgroundColor: Colors.lightBlue,
				elevation: 4.0
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 1)
    );
	}

  List<Segment> _buildPanelSegments(CaregiverPlansLoadSuccess state, context) {
	  var activePlans = state.plans.where((blueprint) => (blueprint.isActive)).toList();
	  var deactivatedPlans = state.plans.where((blueprint) => (!blueprint.isActive)).toList();
	  return [
		  _getPlansSegment(
			  plans: activePlans,
			  title: '$_pageKey.content.addedActivePlansTitle',
				subtitle: '$_pageKey.content.addedActivePlansSubtitle',
				headerAction: UIButton('$_pageKey.header.addPlan', () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name), AppColors.caregiverButtonColor, Icons.add),
			  noElementsAction: deactivatedPlans.isEmpty ? RaisedButton(
				  child: Text(AppLocales.of(context).translate('$_pageKey.header.addPlan'),
						  style: Theme.of(context).textTheme.button),
				  onPressed: () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name)
			  ) : SizedBox.shrink(),
			  context: context
		  ),
		  if (deactivatedPlans.isNotEmpty)
			  _getPlansSegment(
					plans: deactivatedPlans,
					title: '$_pageKey.content.addedDeactivatedPlansTitle',
					subtitle: '$_pageKey.content.addedDeactivatedPlansSubtitle',
					context: context
				)
	  ];
  }

  Segment _getPlansSegment({List<UIPlan> plans, String title, UIButton headerAction, String subtitle, String noElementsMessage, Widget noElementsAction, context}) {
	  return Segment(
		  title: title,
			subtitle: subtitle,
			headerAction: headerAction,
		  noElementsMessage: '$_pageKey.content.noPlansAdded',
		  noElementsAction: noElementsAction,
		  elements: <Widget>[
			  for (var plan in plans)
				  ItemCard(
					  title: plan.name,
					  subtitle: plan.description(context),
						onTapped: () => Navigator.of(context).pushNamed(AppPage.planDetails.name, arguments: plan.id),
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
}
