// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:intl/intl.dart';

import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/string_utils.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';

import 'item_card.dart';

class RewardItemCard extends StatelessWidget {
	final UIReward reward;
	final bool active;
	final bool showPrice;
	final bool showSubtitle;
	final double graphicHeight;

	final double progressPercentage;
	final Color activeProgressBarColor;
	final ItemCardActionButton actionButton;
	final List<UIButton> menuItems;
	final Function onTapped;

	final String _rewardsKey = 'rewards';

  const RewardItemCard({this.reward, this.showPrice = true, this.showSubtitle = true, this.graphicHeight, this.onTapped,
			this.active = true, this.progressPercentage, this.actionButton, this.activeProgressBarColor, this.menuItems});

  @override
  Widget build(BuildContext context) {
  	String subtitle;
  	if (showSubtitle) {
  		if (reward is UIChildReward) {
  		  subtitle = AppLocales.of(context).translate('$_rewardsKey.claimDateLabel') + ' ' +
					  DateFormat.yMd(AppLocales.instance.locale.toString()).format((reward as UIChildReward).date).toString();
  		} else {
  		  subtitle = AppLocales.of(context).translate((reward.limit != null || reward.limit == 0 ) ?
			  '$_rewardsKey.limitedReward' : '$_rewardsKey.unlimitedReward', {'REWARD_LIMIT': reward.limit.toString()});
  		}
	  }
		return ItemCard(
			title: reward.name,
			subtitle: subtitle,
			graphic: reward.icon,
			graphicType: AssetType.rewards,
			graphicHeight: graphicHeight,
			onTapped: onTapped,
			progressPercentage: progressPercentage,
			menuItems: menuItems,
			actionButton: actionButton,
			activeProgressBarColor: activeProgressBarColor,
			chips: [
				if (showPrice)
					AttributeChip.withCurrency(
						currencyType: reward.cost.type,
						content: reward.cost.quantity.toString(),
						tooltip: AppLocales.of(context).translate('$_rewardsKey.claimCostLabel')
					)
			],
			isActive: active
		);
  }
}

class ChildItemCard extends StatelessWidget {
	final UIChild child;
	final Function onTapped;

	const ChildItemCard({@required this.child, this.onTapped});

	@override
	Widget build(BuildContext context) {
		return ItemCard(
				title: child.name,
				subtitle: getChildCardSubtitle(context, child),
				onTapped: onTapped,
				graphicType: AssetType.avatars,
				graphic: child.avatar,
				chips: <Widget>[
					for (UIPoints pointCurrency in child.points)
						AttributeChip.withCurrency(content: '${pointCurrency.quantity}', currencyType: pointCurrency.type, tooltip: pointCurrency.title)
				]
		);
	}
}
