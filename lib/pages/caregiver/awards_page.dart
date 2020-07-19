import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/utils/app_locales.dart';

import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/attribute_chip.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverAwardsPage extends StatefulWidget {
	@override
	_CaregiverAwardsPageState createState() => new _CaregiverAwardsPageState();
}

class _CaregiverAwardsPageState extends State<CaregiverAwardsPage> {
	static const String _commonKey = 'page.caregiverSection.awards';
	
	@override
	Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppHeader.normal(title: '$_commonKey.header.title', text: '$_commonKey.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.add, '$_commonKey.header.addAward', () => { log("Dodaj nagrodę") }),
						HeaderActionButton.normal(Icons.add, '$_commonKey.header.addBadge', () => { log("Dodaj odznakę") })
					]),
					AppSegments(
						segments: [
							Segment(
								title: '$_commonKey.content.addedAwardsTitle',
								noElementsMessage: '$_commonKey.content.noAwardsAdded',
								noElementsAction: RaisedButton(
									child: Text(
										AppLocales.of(context).translate('$_commonKey.header.addAward'),
										style: Theme.of(context).textTheme.button
									),
									onPressed: () => {},
								),
								elements: <Widget>[
									ItemCard(
										title: "Wycieczka do Zoo", 
										subtitle: "Limit 2 na dziecko",
										menuItems: [
											ItemCardMenuItem(text: "actions.edit", onTapped: () => {log("edit")}),
											ItemCardMenuItem(text: "actions.delete", onTapped: () => {log("delete")})
										],
										image: true,
										chips: <Widget>[
											AttributeChip.withCurrency(content: "30", currencyType: CurrencyType.diamond, tooltip: '$_commonKey.content.pointCost')
										],
									)
								]
							),
							Segment(
								title: '$_commonKey.content.addedBadgesTitle',
								noElementsMessage: '$_commonKey.content.noBadgesAdded',
								noElementsAction: RaisedButton(
									child: Text(
										AppLocales.of(context).translate('$_commonKey.header.addBadge'),
										style: Theme.of(context).textTheme.button
									),
									onPressed: () => {},
								),
								elements: <Widget>[]
							)
						]
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 2)
    );
	}
}
