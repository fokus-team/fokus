import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/navigation/child_dashboard_params.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/logic/caregiver/caregiver_panel_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/widgets/cards/model_cards.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverPanelPage extends StatelessWidget {
	static const String _pageKey = 'page.caregiverSection.panel';

	@override
	Widget build(BuildContext context) {
    return Scaffold(
			appBar: CustomAppBar(type: CustomAppBarType.greetings),
			body: BlocListener<AuthenticationBloc, AuthenticationState>(
				listenWhen: (oldState, newState) => newState.status != AuthenticationStatus.unauthenticated,
				listener: (context, state) {
				  BlocProvider.of<CaregiverPanelCubit>(context).reload();
				},
				child: SimpleStatefulBlocBuilder<CaregiverPanelCubit, CaregiverPanelState>(
					builder: (context, state) => AppSegments(
						segments: _buildPanelSegments(state, context),
						fullBody: true
					),
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

	List<Segment> _buildPanelSegments(CaregiverPanelState state, BuildContext context) {
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
					for (var child in state.children)
						ChildItemCard(
							child: child,
							onTapped: () => Navigator.of(context).pushNamed(AppPage.caregiverChildDashboard.name, arguments: ChildDashboardParams(child: child))
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
