import 'package:flutter/material.dart';

import '../../logic/caregiver/caregiver_plans_cubit.dart';
import '../../model/db/plan/plan.dart';
import '../../model/ui/app_page.dart';
import '../../model/ui/ui_button.dart';
import '../../services/app_locales.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/ui/theme_config.dart';
import '../../widgets/app_navigation_bar.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/chips/attribute_chip.dart';
import '../../widgets/custom_app_bars.dart';
import '../../widgets/segment.dart';
import '../../widgets/stateful_bloc_builder.dart';

class CaregiverPlansPage extends StatelessWidget {
	static const String _pageKey = 'page.caregiverSection.plans';
	
  @override
  Widget build(BuildContext context) {
		return Scaffold(
			appBar: CustomAppBar(type: CustomAppBarType.normal, title: '$_pageKey.header.title', subtitle: '$_pageKey.header.pageHint', icon: Icons.description),
			body: StatefulBlocBuilder<CaregiverPlansCubit, CaregiverPlansData>(
				builder: (context, state) => AppSegments(segments: _buildPanelSegments(state.data!, context), fullBody: true),
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

  List<Segment> _buildPanelSegments(CaregiverPlansData state, context) {
	  var activePlans = state.plans.where((blueprint) => (blueprint.active!)).toList();
	  var deactivatedPlans = state.plans.where((blueprint) => (!blueprint.active!)).toList();
	  return [
		  _getPlansSegment(
			  plans: activePlans,
			  title: '$_pageKey.content.addedActivePlansTitle',
				subtitle: '$_pageKey.content.addedActivePlansSubtitle',
				headerAction: UIButton('$_pageKey.header.addPlan', () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name), AppColors.caregiverButtonColor, Icons.add),
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

  Segment _getPlansSegment({required List<Plan> plans, required String title, UIButton? headerAction, required String subtitle, context}) {
	  return Segment(
		  title: title,
			subtitle: subtitle,
			headerAction: headerAction,
		  noElementsMessage: '$_pageKey.content.noPlansAdded',
		  elements: <Widget>[
			  for (var plan in plans)
				  ItemCard(
					  title: plan.name!,
					  subtitle: plan.description,
						onTapped: () => navigateChecked(context, AppPage.planDetails, arguments: plan.id),
					  chips: <Widget>[
						  AttributeChip.withIcon(
							  content: AppLocales.of(context).translate('$_pageKey.content.tasks', {'NUM_TASKS': plan.tasks!.length}),
							  color: Colors.indigo,
							  icon: Icons.layers
						  )
					  ]
				  )
		  ]
	  );
  }
}
