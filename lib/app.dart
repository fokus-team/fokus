import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/pages/loading_page.dart';
import 'package:fokus/pages/main_page.dart';
import 'package:fokus/pages/caregiver_panel_page.dart';
import 'package:fokus/pages/child_panel_page.dart';

import 'data/repository/database/data_repository.dart';

void main() => runApp(
	RepositoryProvider(
		create: (context) => DataRepository(),
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
			initialRoute: '/loading-screen',
			routes: {
				'/loading-screen': (context) => LoadingPage(),
				'/main-page': (context) => MainPage(),
				'/caregiver-panel-page': (context) => CaregiverPanelPage(),
				'/child-panel-page': (context) => ChildPanelPage(),
			},
			theme: ThemeData(
				primaryColor: ThemeConfig.mainBackgroundColor,
        fontFamily: 'Lato',
        textTheme: TextTheme(
          // Will probably change over time
          headline1: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: ThemeConfig.darkTextColor), // Main headline before lists
          headline2: TextStyle(fontSize: 22.0, fontWeight: FontWeight.normal, color: ThemeConfig.darkTextColor), // For headers inside list elements
          subtitle2: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: ThemeConfig.mediumTextColor), // Little subtitle for headline2
          bodyText1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: ThemeConfig.darkTextColor), // Classic body text on light background
          bodyText2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: ThemeConfig.lightTextColor), // Classic body text on color
          button: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: ThemeConfig.lightTextColor) // (Almost always white) button text
        ),
			),
		);
	}
}
