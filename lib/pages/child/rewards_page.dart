import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import 'package:fokus/logic/child/child_rewards_cubit.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/model_cards.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

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
				verticalDirection: VerticalDirection.up,
	      children: [
		      SimpleStatefulBlocBuilder<ChildRewardsCubit, ChildRewardsState>(
				    builder: (context, state) => AppSegments(
							segments: [
								Segment(
									title: '$_pageKey.rewardsTitle',
									subtitle: '$_pageKey.rewardsHint',
									noElementsMessage: '$_pageKey.noRewardsMessage',
									elements: _buildRewardShop(state, context)
								),
								if(state.claimedRewards.isNotEmpty)
									Segment(
										title: '$_pageKey.claimedRewardsTitle',
										elements: _buildRewardHistory(state)
									)
							]
						),
			      listener: (context, state) {
				      if (state.submitted)
					      showSuccessSnackbar(context, '$_pageKey.rewardClaimedText');
			      },
						expandLoader: true,
			      popConfig: SubmitPopConfig(),
		      ),
					BlocBuilder<ChildRewardsCubit, StatefulState>(
						builder: (context, state) => CustomChildAppBar(points: state is ChildRewardsState ? state.points : null)
					)
	      ]
      ),
      bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 1)
    );
  }

	List<Widget> _buildRewardShop(ChildRewardsState state, BuildContext context) {
		return state.rewards.map((reward) {
			double percentage = (state.points.firstWhereOrNull((element) => element.type == reward.cost!.type)?.quantity ?? 0) / reward.cost!.quantity!;
			return RewardItemCard(
				reward: reward,
				graphicHeight: 56.0,
				progressPercentage: percentage >= 1.0 ? 1.0 : percentage,
				activeProgressBarColor: AppColors.currencyColor[reward.cost!.type]!,
				actionButton: ItemCardActionButton(
					color: AppColors.currencyColor[reward.cost!.type]!,
					icon: Icons.add,
					disabled: percentage < 1.0,
					onTapped: () => showRewardDialog(
						context,
						reward,
						claimFeedback: () => BlocProvider.of<ChildRewardsCubit>(context).claimReward(reward),
					)
				)
			);
		}).toList();
	}

	List<Widget> _buildRewardHistory(ChildRewardsState state) {
		return (state.claimedRewards..sort((a, b) => -a.date!.compareTo(b.date!))).map((reward) {
			return RewardItemCard(
				reward: reward,
				graphicHeight: 40.0,
				active: false,
				showPrice: false,
			);
		}).toList();
	}

}
