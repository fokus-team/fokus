import 'package:flutter/material.dart';

import '../../logic/caregiver/caregiver_panel_cubit.dart';
import '../../model/navigation/child_dashboard_params.dart';
import '../../model/ui/app_page.dart';
import '../../model/ui/ui_button.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/dialog_utils.dart';
import '../../utils/ui/theme_config.dart';
import '../../widgets/app_navigation_bar.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/cards/model_cards.dart';
import '../../widgets/custom_app_bars.dart';
import '../../widgets/segment.dart';
import '../../widgets/stateful_bloc_builder.dart';

class CaregiverPanelPage extends StatelessWidget {
	static const String _pageKey = 'page.caregiverSection.panel';

	@override
	Widget build(BuildContext context) {
    return Scaffold(
			appBar: CustomAppBar(type: CustomAppBarType.greetings),
			body: StatefulBlocBuilder<CaregiverPanelCubit, CaregiverPanelData>(
				builder: (context, state) => AppSegments(
					segments: _buildPanelSegments(state.data!, context),
					fullBody: true
				),
			),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => Navigator.of(context).pushNamed(AppPage.caregiverRatingPage.name),
				label: Text(AppLocales.of(context).translate('$_pageKey.header.rateTasks')),
				icon: Icon(Icons.rate_review),
				backgroundColor: Colors.lightBlue,
				elevation: 4.0
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 0)
    );
	}

	List<Segment> _buildPanelSegments(CaregiverPanelData state, BuildContext context) {
		return [
			Segment(
				title: '$_pageKey.content.childProfilesTitle',
				subtitle: '$_pageKey.content.childProfilesSubtitle',
				noElementsMessage: '$_pageKey.content.noChildProfilesAdded',
				headerAction: UIButton(
					'$_pageKey.header.addChild',
					() => Navigator.of(context).pushNamed(AppPage.childSignInPage.name),
					AppColors.caregiverButtonColor,
					Icons.add
				),
				elements: <Widget>[
					for (var child in state.childCards)
						ChildItemCard(
							childCard: child,
							onTapped: () => Navigator.of(context).pushNamed(AppPage.caregiverChildDashboard.name, arguments: ChildDashboardParams(childCard: child))
						),
				]
			),
			Segment(
				title: '$_pageKey.content.caregiverProfilesTitle',
				subtitle: '$_pageKey.content.caregiverProfilesSubtitle',
				noElementsMessage: '$_pageKey.content.noCaregiverProfilesAdded',
				headerAction: UIButton('$_pageKey.header.addCaregiver', () => showAddFriendDialog(context), AppColors.caregiverButtonColor, Icons.add),
				elements: <Widget>[
					if (state.friends != null)
						for (var friend in state.friends!.entries)
							ItemCard(
								title: friend.value,
								rightIcon: Icon(Icons.chevron_right, color: Colors.grey),
								onTapped: () => Navigator.of(context).pushNamed(AppPage.caregiverFriendPlans.name, arguments: friend)
							)
				]
			)
		];
	}
}
