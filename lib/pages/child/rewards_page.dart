import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/child/child_rewards_cubit.dart';
import '../../logic/common/stateful/stateful_cubit.dart';
import '../../utils/ui/dialog_utils.dart';
import '../../utils/ui/snackbar_utils.dart';
import '../../utils/ui/theme_config.dart';
import '../../widgets/app_navigation_bar.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/cards/model_cards.dart';
import '../../widgets/custom_app_bars.dart';
import '../../widgets/segment.dart';
import '../../widgets/stateful_bloc_builder.dart';

class ChildRewardsPage extends StatefulWidget {
	@override
	_ChildRewardsPageState createState() => _ChildRewardsPageState();
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
		      StatefulBlocBuilder<ChildRewardsCubit, ChildRewardsData>(
				    builder: (context, state) => AppSegments(
							segments: [
								Segment(
									title: '$_pageKey.rewardsTitle',
									subtitle: '$_pageKey.rewardsHint',
									noElementsMessage: '$_pageKey.noRewardsMessage',
									elements: _buildRewardShop(state.data!, context)
								),
								if(state.data!.claimedRewards.isNotEmpty)
									Segment(
										title: '$_pageKey.claimedRewardsTitle',
										elements: _buildRewardHistory(state.data!)
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
					BlocBuilder<ChildRewardsCubit, StatefulState<ChildRewardsData>>(
						builder: (context, state) => CustomChildAppBar(points: state.loaded ? state.data!.points : null)
					)
	      ]
      ),
      bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 1)
    );
  }

	List<Widget> _buildRewardShop(ChildRewardsData state, BuildContext context) {
		return state.rewards.map((reward) {
			var percentage = (state.points.firstWhereOrNull((element) => element.type == reward.cost!.type)?.quantity ?? 0) / reward.cost!.quantity!;
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

	List<Widget> _buildRewardHistory(ChildRewardsData state) {
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
