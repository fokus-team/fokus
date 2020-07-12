import 'package:flutter/material.dart';
import 'package:fokus/data/model/navigation_item.dart';
import 'package:fokus/data/model/user/user.dart';
import 'package:fokus/utils/app_locales.dart';

class AppBottomNavigationBar extends StatefulWidget {
	final int currentIndex;
	final Color selectedItemColor;
	final List<AppBottomNavigationItem> items;
	final User user;

	static final	List<AppBottomNavigationItem> caregiverNavigationItems = [
		AppBottomNavigationItem(
			navigationRoute: '/caregiver/panel-page',
			icon: Icon(Icons.assignment_ind),
			title: 'navigation.caregiver.panel',
		),
		AppBottomNavigationItem(
			navigationRoute: '/caregiver/plans-page',
			icon: Icon(Icons.description),
			title: 'navigation.caregiver.plans',
		),
		AppBottomNavigationItem(
			navigationRoute: '/caregiver/awards-page',
			icon: Icon(Icons.stars),
			title: 'navigation.caregiver.awards',
		),
		AppBottomNavigationItem(
			navigationRoute: '/caregiver/statistics-page',
			icon: Icon(Icons.insert_chart),
			title: 'navigation.caregiver.statistics',
		),
	];

	AppBottomNavigationBar({this.currentIndex, this.selectedItemColor, this.items, this.user});
	AppBottomNavigationBar.caregiverPage({int currentIndex, Color selectedItemColor, User user}) : this(
		currentIndex: currentIndex,
		selectedItemColor: selectedItemColor,
		items: caregiverNavigationItems,
		user: user
	);

  @override
  _AppBottomNavigationBarState createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
	@override
	Widget build(BuildContext context) {
		return BottomNavigationBar(
			currentIndex: widget.currentIndex,
			type: BottomNavigationBarType.fixed,
			showUnselectedLabels: true,
			unselectedFontSize: 14,
			selectedFontSize: 14,
			unselectedItemColor: Colors.grey[600],
			selectedItemColor: widget.selectedItemColor,
			onTap: (int index) => index != widget.currentIndex ? Navigator.of(context).pushNamed(widget.items[index].navigationRoute, arguments: widget.user) : {},
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
