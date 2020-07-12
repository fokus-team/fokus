import 'package:flutter/material.dart';
import 'package:fokus/data/model/navigation_item.dart';

import 'package:fokus/pages/caregiver/panel_page.dart';
import 'package:fokus/pages/caregiver/plans_page.dart';
import 'package:fokus/pages/caregiver/awards_page.dart';
import 'package:fokus/pages/caregiver/statistics_page.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/wigets/page_theme.dart';

class CaregiverMainPage extends StatefulWidget {
	@override
	_CaregiverMainPageState createState() => new _CaregiverMainPageState();
}

class _CaregiverMainPageState extends State<CaregiverMainPage> {
	int _currentIndex = 0;
	
	List<AppBottomNavigationItem> navigation = [
		AppBottomNavigationItem(
			page: CaregiverPanelPage(),
			icon: Icon(Icons.assignment_ind),
			title: 'navigation.caregiver.panel',
		),
		AppBottomNavigationItem(
			page: CaregiverPlansPage(),
			icon: Icon(Icons.description),
			title: 'navigation.caregiver.plans',
		),
		AppBottomNavigationItem(
			page: CaregiverAwardsPage(),
			icon: Icon(Icons.stars),
			title: 'navigation.caregiver.awards',
		),
		AppBottomNavigationItem(
			page: CaregiverStatisticsPage(),
			icon: Icon(Icons.insert_chart),
			title: 'navigation.caregiver.statistics',
		),
	];
	
  @override
  Widget build(BuildContext context) {
    return PageTheme.caregiverSection(
      child: Scaffold(
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
				selectedItemColor: AppColors.mainBackgroundColor,
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
      ),
    );
  }

}
