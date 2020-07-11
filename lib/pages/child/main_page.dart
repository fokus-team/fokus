import 'package:flutter/material.dart';
import 'package:fokus/data/model/navigation_item.dart';

import 'package:fokus/pages/child/plans_page.dart';
import 'package:fokus/pages/child/awards_page.dart';
import 'package:fokus/pages/child/achievements_page.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class ChildMainPage extends StatefulWidget {
	@override
	_ChildMainPageState createState() => new _ChildMainPageState();
}

class _ChildMainPageState extends State<ChildMainPage> {
	int _currentIndex = 0;
	
	List<AppBottomNavigationItem> navigation = [
		AppBottomNavigationItem(
			page: ChildPlansPage(),
			icon: Icon(Icons.description),
			title: 'navigation.child.plans',
		),
		AppBottomNavigationItem(
			page: ChildAwardsPage(),
			icon: Icon(Icons.stars),
			title: 'navigation.child.awards',
		),
		AppBottomNavigationItem(
			page: ChildAchievementsPage(),
			icon: Icon(Icons.assistant),
			title: 'navigation.child.achievements',
		),
	];
	
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (final navigationItem in navigation) navigationItem.page,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
				type: BottomNavigationBarType.fixed,
				showUnselectedLabels: true,
				unselectedFontSize: 14,
				selectedFontSize: 14,
				unselectedItemColor: Colors.grey[600],
				selectedItemColor: AppColors.childBackgroundColor,
        onTap: (int index) => setState(() => _currentIndex = index),
        items: [
          for (final navigationItem in navigation)
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
      ),
    );
  }

}
