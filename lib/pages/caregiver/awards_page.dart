import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/logic/caregiver_awards_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';

import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
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
						HeaderActionButton.normal(Icons.add, '$_pageKey.header.addAward', 
						() => Navigator.of(context).pushNamed(AppPage.caregiverAwardForm.name, arguments: AppFormType.create)),
						HeaderActionButton.normal(Icons.add, '$_pageKey.header.addBadge', 
						() => Navigator.of(context).pushNamed(AppPage.caregiverBadgeForm.name, arguments: AppFormType.create))
					]),
					LoadableBlocBuilder<CaregiverAwardsCubit>(
						builder: (context, state) => AppSegments(segments: _buildPanelSegments(state, context))
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 2)
    );
	}
	
	List<Segment> _buildPanelSegments(CaregiverAwardsLoadSuccess state, context) {
		var awards = state.awards;

		return [
			Segment(
				title: '$_pageKey.content.addedAwardsTitle',
				noElementsMessage: '$_pageKey.content.noAwardsAdded',
				noElementsAction: RaisedButton(
					child: Text(
						AppLocales.of(context).translate('$_pageKey.header.addAward'),
						style: Theme.of(context).textTheme.button
					),
					onPressed: () => { Navigator.of(context).pushNamed(AppPage.caregiverAwardForm.name) }
				),
				elements: <Widget>[
					for (var award in awards)
						ItemCard(
							title: award.name, 
							subtitle: AppLocales.of(context).translate((award.limit != null || award.limit == 0 ) ? 
								'$_pageKey.content.limitedAward' : '$_pageKey.content.unlimitedAward', {'AWARD_LIMIT': award.limit.toString()}),
							menuItems: [
								UIButton.ofType(ButtonType.edit, () => {log("edit")}),
								UIButton.ofType(ButtonType.delete, () => {log("delete")})
							],
							graphicType: GraphicAssetType.awardsIcons,
							graphic: award.icon,
							chips: <Widget>[
								if(award.cost != null)
									AttributeChip.withCurrency(content: award.cost.quantity.toString(), currencyType: award.cost.type, tooltip: '$_pageKey.content.pointCost')
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
					onPressed: () => { Navigator.of(context).pushNamed(AppPage.caregiverBadgeForm.name) }
				),
				elements: <Widget>[
					ItemCard(
						title: "Super planista", 
						subtitle: AppLocales.of(context).translate('$_pageKey.content.3LeveledBadge'),
						menuItems: [
							UIButton.ofType(ButtonType.edit, () => {log("edit")}),
							UIButton.ofType(ButtonType.delete, () => {log("delete")})
						],
						graphicType: GraphicAssetType.badgeIcons,
						graphic: 3,
						graphicHeight: 44.0,
					)
				]
			)
		];
	}
}
