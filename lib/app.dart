import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/pages/main_page.dart';

void main() => runApp(FokusApp());

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
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			home: MainPage(title: 'Fokus'),
		);
	}
}
