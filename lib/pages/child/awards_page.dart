import 'package:flutter/material.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/gamification/ui_award.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/segment.dart';

class ChildAwardsPage extends StatefulWidget {
	@override
	_ChildAwardsPageState createState() => new _ChildAwardsPageState();
}

class _ChildAwardsPageState extends State<ChildAwardsPage> {
  static const String _pageKey = 'page.childSection.awards.content';

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					ChildCustomHeader(),
					AppSegments(
						segments: [
							Segment(
								title: '$_pageKey.awardsTitle',
								noElementsMessage: '$_pageKey.noAwardsMessage',
								elements: <Widget>[
									ItemCard(
										title: '1 godzina gry na konsoli',
										subtitle: AppLocales.of(context).translate('$_pageKey.claimCostLabel') + ':',
										graphic: 9,
										graphicType: GraphicAssetType.awardsIcons,
										graphicHeight: 44.0,
										progressPercentage: 1,
										activeProgressBarColor: AppColors.childActionColor,
										chips: [
											AttributeChip.withCurrency(
												currencyType: CurrencyType.diamond,
												content: '20',
											)
										],
										actionButton: ItemCardActionButton(
											color: AppColors.childActionColor,
											icon: Icons.add_box,
											onTapped: () => showAwardDialog(context, UIAward(name: 'Zakupomania', icon: 13, points: UIPoints(quantity: 900, type: CurrencyType.diamond)))
										)
									),
									ItemCard(
										title: 'Zakupomania',
										subtitle: AppLocales.of(context).translate('$_pageKey.claimCostLabel') + ':',
										graphic: 13,
										graphicType: GraphicAssetType.awardsIcons,
										graphicHeight: 44.0,
										progressPercentage: 0.1,
										activeProgressBarColor: AppColors.childActionColor,
										chips: [
											AttributeChip.withCurrency(
												currencyType: CurrencyType.diamond,
												content: '200',
											)
										],
										actionButton: ItemCardActionButton(
											disabled: true,
											color: AppColors.childActionColor,
											icon: Icons.add_box,
											onTapped: () => showAwardDialog(context, UIAward(name: 'Zakupomania', icon: 13, points: UIPoints(quantity: 900, type: CurrencyType.diamond)))
										)
									)
								]
							),
							// TODO Show only if there are any claimed awards
							Segment(
								title: '$_pageKey.content.claimedAwardsTitle',
								elements: <Widget>[
									ItemCard(
										title: '1 godzina gry na konsoli',
										subtitle: 'Odebrano 09.08.2020',
										graphic: 9,
										graphicType: GraphicAssetType.awardsIcons,
										graphicHeight: 44.0,
										isActive: false
									)
								]
							)
						]
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 1)
		);
	}
}
