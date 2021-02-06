import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/caregiver/caregiver_awards_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';

import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/model_cards.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverAwardsPage extends StatefulWidget {
	@override
	_CaregiverAwardsPageState createState() => new _CaregiverAwardsPageState();
}

class _CaregiverAwardsPageState extends State<CaregiverAwardsPage> {
	static const String _pageKey = 'page.caregiverSection.awards';
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: CustomAppBar(type: CustomAppBarType.normal, title: '$_pageKey.header.title', subtitle: '$_pageKey.header.pageHint', icon: Icons.stars),
			body: StatefulBlocBuilder<CaregiverAwardsCubit, CaregiverAwardsState>(
				builder: (context, state) => AppSegments(segments: _buildPanelSegments(state, context), fullBody: true),
				listener: (context, state) {
					if (state.submitted) {
						var snackbarText = state is BadgeRemovedState ? 'badgeRemovedText' : 'rewardRemovedText';
						showSuccessSnackbar(context, '$_pageKey.content.$snackbarText');
					}
				},
				popOnSubmit: true,
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 2)
    );
	}

	List<Segment> _buildPanelSegments(CaregiverAwardsState state, BuildContext context) {
		return [
			Segment(
				title: '$_pageKey.content.addedRewardsTitle',
				subtitle: '$_pageKey.content.addedRewardsSubtitle',
				headerAction: UIButton('$_pageKey.header.addReward', () => Navigator.of(context).pushNamed(AppPage.caregiverRewardForm.name), AppColors.caregiverButtonColor, Icons.add),
				noElementsMessage: '$_pageKey.content.noRewardsAdded',
				elements: <Widget>[
					for (var reward in state.rewards)
						RewardItemCard(
							reward: reward,
							menuItems: [
								UIButton.ofType(ButtonType.edit, () => Navigator.of(context).pushNamed(AppPage.caregiverRewardForm.name, arguments: reward.id), null, Icons.edit),
								UIButton.ofType(ButtonType.delete, () {
									showBasicDialog(
										context,
										GeneralDialog.confirm(
											title: AppLocales.of(context).translate('$_pageKey.content.removeRewardTitle'),
											content: AppLocales.of(context).translate('$_pageKey.content.removeRewardText'),
											confirmColor: Colors.red,
											confirmText: 'actions.delete',
											confirmAction: () => context.read<CaregiverAwardsCubit>().removeReward(reward.id)
										)
									);
								}, null, Icons.delete)
							],
							onTapped: () => showRewardDialog(context, reward),
						)
				]
			),
			Segment(
				title: '$_pageKey.content.addedBadgesTitle',
				subtitle: '$_pageKey.content.addedBadgesSubtitle',
				headerAction: UIButton('$_pageKey.header.addBadge', () => Navigator.of(context).pushNamed(AppPage.caregiverBadgeForm.name), AppColors.caregiverButtonColor, Icons.add),
				noElementsMessage: '$_pageKey.content.noBadgesAdded',
				elements: <Widget>[
					for (var badge in state.badges)
						ItemCard(
							title: badge.name, 
							subtitle: badge.description != null ? badge.description : AppLocales.of(context).translate('$_pageKey.content.noDescriptionSubtitle'),
							menuItems: [
								UIButton.ofType(ButtonType.delete, () {
									showBasicDialog(context,
										GeneralDialog.confirm(
											title: AppLocales.of(context).translate('$_pageKey.content.removeBadgeTitle'),
											content: AppLocales.of(context).translate('$_pageKey.content.removeBadgeText'),
											confirmColor: Colors.red,
											confirmText: 'actions.delete',
											confirmAction: () => context.read<CaregiverAwardsCubit>().removeBadge(badge)
										)
									);
								}, null, Icons.delete)
							],
							onTapped: () => showBadgeDialog(context, badge, showHeader: false),
							graphicType: AssetType.badges,
							graphic: badge.icon,
							graphicHeight: 44.0
						)
				]
			)
		];
	}
}
