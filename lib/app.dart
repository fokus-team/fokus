import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:fokus/bloc/active_user/active_user_cubit.dart';
import 'package:fokus/pages/caregiver/awards_page.dart';
import 'package:fokus/pages/caregiver/panel_page.dart';
import 'package:fokus/pages/caregiver/plans_page.dart';
import 'package:fokus/pages/caregiver/statistics_page.dart';
import 'package:fokus/pages/child/achievements_page.dart';
import 'package:fokus/pages/child/awards_page.dart';
import 'package:fokus/pages/child/panel_page.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/pages/loading_page.dart';
import 'package:fokus/pages/roles_page.dart';
import 'package:fokus/wigets/page_theme.dart';

import 'data/model/app_page.dart';

void main() => runApp(
	CubitProvider<ActiveUserCubit>(
		create: (context) => ActiveUserCubit(),
		child: FokusApp(),
	)
);

class FokusApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Fokus',
			localizationsDelegates: [
				AppLocales.delegate,
				GlobalMaterialLocalizations.delegate,
				GlobalWidgetsLocalizations.delegate,
				GlobalCupertinoLocalizations.delegate,
			],
			supportedLocales: [
				const Locale('en', 'US'),
				const Locale('pl', 'PL'),
			],
			initialRoute: AppPage.loadingPage.name,
			routes: {
				AppPage.loadingPage.name: (context) => PageTheme.loginSection(child: LoadingPage()),
				AppPage.rolesPage.name: (context) => PageTheme.loginSection(child: RolesPage()),
				AppPage.caregiverPanel.name: (context) => PageTheme.caregiverSection(child: CaregiverPanelPage()),
				AppPage.caregiverPlans.name: (context) => PageTheme.caregiverSection(child: CaregiverPlansPage()),
				AppPage.caregiverAwards.name: (context) => PageTheme.caregiverSection(child: CaregiverAwardsPage()),
				AppPage.caregiverStatistics.name: (context) => PageTheme.caregiverSection(child: CaregiverStatisticsPage()),
				AppPage.childPanel.name: (context) => PageTheme.childSection(child: ChildPanelPage()),
				AppPage.childAwards.name: (context) => PageTheme.childSection(child: ChildAwardsPage()),
				AppPage.childAchievements.name: (context) => PageTheme.childSection(child: ChildAchievementsPage()),
			},
			theme: ThemeData(
				primaryColor: AppColors.mainBackgroundColor,
        fontFamily: 'Lato',
        textTheme: TextTheme(
          // Will probably change over time
          headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: AppColors.darkTextColor), // Main headline before lists
          headline2: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: AppColors.darkTextColor), // For headers inside list elements
          subtitle2: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: AppColors.mediumTextColor), // Little subtitle for headline2
          bodyText1: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal, color: AppColors.lightTextColor), // Classic body text on light background
          bodyText2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal, color: AppColors.darkTextColor), // Classic body text on color
          button: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.lightTextColor) // (Almost always white) button text
        ),
			),
		);
	}
}
