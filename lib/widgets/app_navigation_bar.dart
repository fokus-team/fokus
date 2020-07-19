import 'package:flutter/material.dart';
import 'package:fokus/model/app_page.dart';
import 'package:fokus/model/navigation_item.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/utils/app_locales.dart';

class AppNavigationBar extends StatefulWidget {
	final int currentIndex;
	final List<AppBottomNavigationItem> items;

	static final List<AppBottomNavigationItem> caregiverNavigationItems = [
		AppBottomNavigationItem(
			navigationRoute: AppPage.caregiverPanel,
			icon: Icon(Icons.assignment_ind),
			title: 'navigation.caregiver.panel',
		),
		AppBottomNavigationItem(
			navigationRoute: AppPage.caregiverPlans,
			icon: Icon(Icons.description),
			title: 'navigation.caregiver.plans',
		),
		AppBottomNavigationItem(
			navigationRoute: AppPage.caregiverAwards,
			icon: Icon(Icons.stars),
			title: 'navigation.caregiver.awards',
		),
		AppBottomNavigationItem(
			navigationRoute: AppPage.caregiverStatistics,
			icon: Icon(Icons.insert_chart),
			title: 'navigation.caregiver.statistics',
		),
	];

	static final List<AppBottomNavigationItem> childNavigationItems = [
		AppBottomNavigationItem(
			navigationRoute: AppPage.childPanel,
			icon: Icon(Icons.description),
			title: 'navigation.child.plans',
		),
		AppBottomNavigationItem(
			navigationRoute: AppPage.childAwards,
			icon: Icon(Icons.stars),
			title: 'navigation.child.awards',
		),
		AppBottomNavigationItem(
			navigationRoute: AppPage.childAchievements,
			icon: Icon(Icons.assistant),
			title: 'navigation.child.achievements',
		),
	];
	
	AppNavigationBar({this.currentIndex, this.items});
	AppNavigationBar.caregiverPage({int currentIndex, User user}) : this(
		currentIndex: currentIndex,
		items: caregiverNavigationItems
	);
	
	AppNavigationBar.childPage({int currentIndex, User user}) : this(
		currentIndex: currentIndex,
		items: childNavigationItems
	);

  @override
  _AppNavigationBarState createState() => _AppNavigationBarState();

}

class _AppNavigationBarState extends State<AppNavigationBar> {
	@override
	Widget build(BuildContext context) {
		return BottomNavigationBar(
			backgroundColor: Colors.white,
			currentIndex: widget.currentIndex,
			type: BottomNavigationBarType.fixed,
			showUnselectedLabels: true,
			unselectedFontSize: 14,
			selectedFontSize: 14,
			unselectedItemColor: Colors.grey[600],
			selectedItemColor: Theme.of(context).appBarTheme.color,
			onTap: (int index) => index != widget.currentIndex ? Navigator.of(context).pushNamed(widget.items[index].navigationRoute.name) : {},
			items: [
				for (final navigationItem in widget.items)
					BottomNavigationBarItem(
						icon: Padding(
							padding: EdgeInsets.only(top: 4.0, bottom: 2.0),
							child: navigationItem.icon
						),
						title: Padding(
							padding: EdgeInsets.only(bottom: 2.0),
							child: Text(AppLocales.of(context).translate(navigationItem.title))
						)
					)
			],
		);
	}
}
