import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/db/gamification/child_reward.dart';
import '../../model/db/gamification/points.dart';
import '../../model/db/gamification/reward.dart';
import '../../model/ui/child_card_model.dart';
import '../../model/ui/ui_button.dart';
import '../../services/app_locales.dart';
import '../../utils/string_utils.dart';
import '../../utils/ui/icon_sets.dart';
import '../chips/attribute_chip.dart';
import 'item_card.dart';

class RewardItemCard extends StatelessWidget {
	final Reward reward;
	final bool active;
	final bool showPrice;
	final bool showSubtitle;
	final double? graphicHeight;

	final double? progressPercentage;
	final Color? activeProgressBarColor;
	final ItemCardActionButton? actionButton;
	final List<UIButton>? menuItems;
	final void Function()? onTapped;

	final String _rewardsKey = 'rewards';

  const RewardItemCard({required this.reward, this.showPrice = true, this.showSubtitle = true, this.graphicHeight, this.onTapped,
			this.active = true, this.progressPercentage, this.actionButton, this.activeProgressBarColor, this.menuItems});

  @override
  Widget build(BuildContext context) {
  	late String subtitle;
  	if (showSubtitle) {
  		if (reward is ChildReward) {
  			var label = AppLocales.of(context).translate('$_rewardsKey.claimDateLabel');
			  var date = DateFormat.yMd(AppLocales.instance.locale.toString()).format((reward as ChildReward).date!);
  		  subtitle = '$label $date';
  		} else {
  		  subtitle = AppLocales.of(context).translate((reward.limit != null || reward.limit == 0 ) ?
			  '$_rewardsKey.limitedReward' : '$_rewardsKey.unlimitedReward', {'REWARD_LIMIT': reward.limit.toString()});
  		}
	  }
		return ItemCard(
			title: reward.name!,
			subtitle: subtitle,
			graphic: reward.icon,
			graphicType: AssetType.rewards,
			graphicHeight: graphicHeight,
			onTapped: () => onTapped != null ? onTapped!() : null,
			progressPercentage: progressPercentage,
			menuItems: menuItems,
			actionButton: actionButton,
			activeProgressBarColor: activeProgressBarColor,
			chips: [
				if (showPrice)
					AttributeChip.withCurrency(
						currencyType: reward.cost!.type!,
						content: reward.cost!.quantity.toString(),
						tooltip: AppLocales.of(context).translate('$_rewardsKey.claimCostLabel')
					)
			],
			isActive: active
		);
  }
}

class ChildItemCard extends StatelessWidget {
	final ChildCardModel childCard;
	final void Function()? onTapped;

	const ChildItemCard({required this.childCard, this.onTapped});

	@override
	Widget build(BuildContext context) {
		return ItemCard(
				title: childCard.child.name!,
				subtitle: getChildCardSubtitle(context, childCard),
				onTapped: () => onTapped != null ? onTapped!() : null,
				graphicType: AssetType.avatars,
				graphic: childCard.child.avatar,
				chips: <Widget>[
					for (Points pointCurrency in childCard.child.points!)
						AttributeChip.withCurrency(content: '${pointCurrency.quantity}', currencyType: pointCurrency.type!, tooltip: pointCurrency.name)
				]
		);
	}
}
