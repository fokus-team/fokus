import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/logic/caregiver_panel/caregiver_panel_cubit.dart';
import 'package:fokus/model/app_page.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/cubit_utils.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/attribute_chip.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverPanelPage extends StatefulWidget {
	@override
	_CaregiverPanelPageState createState() => new _CaregiverPanelPageState();
}

class _CaregiverPanelPageState extends State<CaregiverPanelPage> {
	@override
	Widget build(BuildContext context) {
    return CubitUtils.navigateOnState<ActiveUserCubit, ActiveUserState, NoActiveUser>(
			navigation: (navigator) => navigator.pushReplacementNamed(AppPage.rolesPage.name),
			child: Scaffold(
				body: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: <Widget>[
						AppHeader.greetings(text: 'page.caregiverSection.panel.header.pageHint', headerActionButtons: [
							HeaderActionButton.normal(Icons.add, 'page.caregiverSection.panel.header.addChild', () => { log("Dodaj dziecko") }),
							HeaderActionButton.normal(Icons.add, 'page.caregiverSection.panel.header.addCaregiver', () => { log("Dodaj opiekuna") })
						]),
						AppSegments(
							segments: [
								Segment(
									title: 'page.caregiverSection.panel.content.childProfilesTitle',
									noElementsMessage: 'page.caregiverSection.panel.content.noChildProfilesAdded',
									elements: <Widget>[
										ItemCard(
											title: "Gosia",
											subtitle: AppLocales.of(context).translate('page.caregiverSection.panel.content.plansTodayCount', {'NUM_PLANS': (2).toString()}) + ' ' +
												AppLocales.of(context).translate('page.caregiverSection.panel.content.plansToday'),
											menuItems: [
												ItemCardMenuItem(text: "actions.details", onTapped: () => {log("details")}),
												ItemCardMenuItem(text: "actions.edit", onTapped: () => {log("edit")}),
												ItemCardMenuItem(text: "actions.delete", onTapped: () => {log("delete")})
											],
											image: true,
											chips: <Widget>[
												AttributeChip.withCurrency(content: "120", currencyType: CurrencyType.diamond)
											]
										)
									]
								),
								Segment(
									title: 'page.caregiverSection.panel.content.caregiverProfilesTitle',
									noElementsMessage: 'page.caregiverSection.panel.content.noCaregiverProfilesAdded',
									elements: <Widget>[
										ItemCard(
											title: "Katarzyna",
											menuItems: [
												ItemCardMenuItem(text: "actions.delete", onTapped: () => {log("delete")})
											],
										)
									]
								)
							]
						)
					]
				),
				bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 0)
	    )
    );
	}
}
