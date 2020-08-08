import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';

import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
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
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppHeader.normal(title: '$_pageKey.header.title', text: '$_pageKey.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.add, '$_pageKey.header.addAward', () => { log("Dodaj nagrodę") }),
						HeaderActionButton.normal(Icons.add, '$_pageKey.header.addBadge', () => { log("Dodaj odznakę") })
					]),
					AppSegments(
						segments: [
							Segment(
								title: '$_pageKey.content.addedAwardsTitle',
								noElementsMessage: '$_pageKey.content.noAwardsAdded',
								noElementsAction: RaisedButton(
									child: Text(
										AppLocales.of(context).translate('$_pageKey.header.addAward'),
										style: Theme.of(context).textTheme.button
									),
									onPressed: () => {},
								),
								elements: <Widget>[
									ItemCard(
										title: "Wycieczka do Zoo", 
										subtitle: AppLocales.of(context).translate('$_pageKey.content.limitedAward', {'AWARD_LIMIT': 2}),
										menuItems: [
											ItemCardMenuItem(text: "actions.edit", onTapped: () => {log("edit")}),
											ItemCardMenuItem(text: "actions.delete", onTapped: () => {log("delete")})
										],
										graphicType: GraphicAssetType.awardsIcons,
										graphic: 16,
										chips: <Widget>[
											AttributeChip.withCurrency(content: "30", currencyType: CurrencyType.diamond, tooltip: '$_pageKey.content.pointCost')
										],
									)
								]
							),
							Segment(
								title: '$_pageKey.content.addedBadgesTitle',
								noElementsMessage: '$_pageKey.content.noBadgesAdded',
								noElementsAction: RaisedButton(
									child: Text(
										AppLocales.of(context).translate('$_pageKey.header.addBadge'),
										style: Theme.of(context).textTheme.button
									),
									onPressed: () => {},
								),
								elements: <Widget>[
									ItemCard(
										title: "Super planista", 
										subtitle: AppLocales.of(context).translate('$_pageKey.content.3LeveledBadge'),
										menuItems: [
											ItemCardMenuItem(text: "actions.edit", onTapped: () => {log("edit")}),
											ItemCardMenuItem(text: "actions.delete", onTapped: () => {log("delete")})
										],
										graphicType: GraphicAssetType.badgeIcons,
										graphic: 3,
									)
								]
							)
						]
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 2)
    );
	}
}
