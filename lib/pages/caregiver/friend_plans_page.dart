import 'package:flutter/material.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverFriendPlansPage extends StatefulWidget {
	@override
	_CaregiverFriendPlansPageState createState() => new _CaregiverFriendPlansPageState();
}

class _CaregiverFriendPlansPageState extends State<CaregiverFriendPlansPage> {
	static const String _pageKey = 'page.caregiverSection.friendPlans';
	
	@override
	Widget build(BuildContext context) {
    return Scaffold(
			appBar: AppBar(
				title: Text("Anna"),
				actions: <Widget>[
					HelpIconButton(helpPage: 'friends'),
					PopupMenuList(
						lightTheme: true,
						items: [
							UIButton.ofType(ButtonType.unpair, () => {})
						]
					)
				]
			),
			body: _buildFriendPlans()
    );
	}

	Widget _buildFriendPlans() {
		List<UIPlan> plans = [];
		return Segment(
			title: '$_pageKey.content.plansTitle',
			noElementsMessage: '$_pageKey.content.noPlansText',
			elements: <Widget>[
			  for (var plan in plans)
				  ItemCard(
					  title: plan.name,
					  subtitle: plan.description(context),
						onTapped: () => Navigator.of(context).pushNamed(AppPage.planDetails.name, arguments: plan.id),
					  chips: <Widget>[
						  AttributeChip.withIcon(
							  content: AppLocales.of(context).translate('$_pageKey.content.tasks', {'NUM_TASKS': plan.taskCount}),
							  color: Colors.indigo,
							  icon: Icons.layers
						  )
					  ]
				  )
			]
		);
	}

}
