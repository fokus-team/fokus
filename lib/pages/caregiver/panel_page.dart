import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:fokus/logic/caregiver_panel_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverPanelPage extends StatefulWidget {
	@override
	_CaregiverPanelPageState createState() => new _CaregiverPanelPageState();
}

class _CaregiverPanelPageState extends State<CaregiverPanelPage> {
	static const String _pageKey = 'page.caregiverSection.panel';
	
	@override
	Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>[
					AppHeader.greetings(text: '$_pageKey.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.add, '$_pageKey.header.addChild', 
							() => { log("Dodaj dziecko") }),
						HeaderActionButton.normal(Icons.rate_review, '$_pageKey.header.rateTasks',
							() => { Navigator.of(context).pushNamed(AppPage.caregiverRatingPage.name) }, Colors.lightBlue)
					]),
					LoadableBlocBuilder<CaregiverPanelCubit>(
						builder: (context, state) => AppSegments(segments: _buildPanelSegments(state))
					),
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 0)
    );
	}

	List<Segment> _buildPanelSegments(CaregiverPanelLoadSuccess state) {
		return [
			Segment(
				title: '$_pageKey.content.childProfilesTitle',
				noElementsMessage: '$_pageKey.content.noChildProfilesAdded',
				elements: <Widget>[
					for (var child in state.children)
						ItemCard(
							title: child.name,
							subtitle: getChildCardSubtitle(context, child),
							onTapped: () => Navigator.of(context).pushNamed(AppPage.caregiverChildDashboard.name),
							graphicType: GraphicAssetType.childAvatars,
							graphic: child.avatar,
							chips: <Widget>[
								for (var currency in child.points.entries)
									AttributeChip.withCurrency(content: '${currency.value}', currencyType: currency.key)
							]
						)
				]
			),
			Segment(
				title: '$_pageKey.content.caregiverProfilesTitle',
				noElementsMessage: '$_pageKey.content.noCaregiverProfilesAdded',
				elements: <Widget>[
					if (state.friends != null)
						for (var friend in state.friends.values)
							ItemCard(
								title: friend,
								menuItems: [
									UIButton.ofType(ButtonType.unpair, () => {log("unpair")})
								],
							)
				]
			)
		];
	}

	String getChildCardSubtitle(BuildContext context, UIChild child) {
		String key = '$_pageKey.content';
		if (child.hasActivePlan)
			return AppLocales.of(context).translate('$key.activePlan');
		return AppLocales.of(context).translate('$key.todayPlans', {'NUM_PLANS': '${child.todayPlanCount}'});
	}
}
