import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/child/child_rewards_cubit.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/model_cards.dart';
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
				mainAxisSize: MainAxisSize.min,
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
										elements: _buildRewardShop(state, context)
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

	void _claimReward(UIReward reward) {
		context.bloc<ChildRewardsCubit>().claimReward(reward);
		Navigator.of(context).pop(); // closing confirm dialog before pushing snackbar
		showSuccessSnackbar(context, '$_pageKey.rewardClaimedText');
	}

	List<Widget> _buildRewardShop(ChildRewardsLoadSuccess state, BuildContext context) {
		return state.rewards.map((reward) {
			double percentage = (state.points.firstWhere((element) => element.type == reward.cost.type, orElse: () => null)?.quantity ?? 0) / reward.cost.quantity;
			return RewardItemCard(
				reward: reward,
				graphicHeight: 56.0,
				progressPercentage: percentage >= 1.0 ? 1.0 : percentage,
				activeProgressBarColor: AppColors.currencyColor[reward.cost.type],
				actionButton: ItemCardActionButton(
					color: AppColors.currencyColor[reward.cost.type],
					icon: Icons.add,
					disabled: percentage < 1.0,
					onTapped: () => showRewardDialog(context, reward, claimFeedback: () => _claimReward(reward))
				)
			);
		}).toList();
	}

	List<Widget> _buildRewardHistory(ChildRewardsLoadSuccess state) {
		return (state.claimedRewards..sort((a, b) => -a.date.compareTo(b.date))).map((reward) {
			return RewardItemCard(
				reward: reward,
				graphicHeight: 40.0,
				active: false,
				showPrice: false,
			);
		}).toList();
	}

}
