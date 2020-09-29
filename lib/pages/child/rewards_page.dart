import 'package:flutter/material.dart';
import 'package:fokus/logic/child_rewards_cubit.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:intl/intl.dart';

class ChildRewardsPage extends StatefulWidget {
	@override
	_ChildRewardsPageState createState() => new _ChildRewardsPageState();
}

class _ChildRewardsPageState extends State<ChildRewardsPage> {
  static const String _pageKey = 'page.childSection.rewards.content';

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					ChildCustomHeader(),
		      LoadableBlocBuilder<ChildRewardsCubit>(
				    builder: (context, state) => 
							AppSegments(
								segments: [
									Segment(
										title: '$_pageKey.rewardsTitle',
										subtitle: '$_pageKey.rewardsHint',
										noElementsMessage: '$_pageKey.noRewardsMessage',
										elements: _buildRewardShop(state)
									),
									if((state as ChildRewardsLoadSuccess).claimedRewards.isNotEmpty)
										Segment(
											title: '$_pageKey.claimedRewardsTitle',
											elements: _buildRewardHistory(state)
										)
								]
							),
						wrapWithExpanded: true,
		      )
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 1)
		);
	}

	List<Widget> _buildRewardShop(ChildRewardsLoadSuccess state) {
		return state.rewards.map((reward) {
			double percentage = (state.points[reward.cost.type] ?? 0) / reward.cost.quantity; 
			return ItemCard(
				title: reward.name,
				subtitle: AppLocales.of(context).translate('$_pageKey.claimCostLabel') + ':',
				graphic: reward.icon,
				graphicType: AssetType.rewards,
				graphicHeight: 44.0,
				progressPercentage: percentage >= 1.0 ? 1.0 : percentage,
				activeProgressBarColor: AppColors.currencyColor[reward.cost.type],
				chips: [
					AttributeChip.withCurrency(
						currencyType: reward.cost.type,
						content: reward.cost.quantity.toString()
					)
				],
				actionButton: ItemCardActionButton(
					color: AppColors.currencyColor[reward.cost.type],
					icon: Icons.add_shopping_cart,
					disabled: percentage < 1.0,
					onTapped: () => showRewardDialog(context, reward)
				)
			);
		}).toList();
	}

	List<Widget> _buildRewardHistory(ChildRewardsLoadSuccess state) {
		return state.claimedRewards.map((reward) {
			return ItemCard(
				title: reward.name,
				subtitle: AppLocales.of(context).translate('$_pageKey.claimDateLabel') + ' ' +
					DateFormat.yMd(Localizations.localeOf(context).toString()).format(reward.date).toString(),
				graphic: reward.icon,
				graphicType: AssetType.rewards,
				graphicHeight: 44.0,
				isActive: false
			);
		}).toList();
	}

}
