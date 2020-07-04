import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:fokus/pages/main_page.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/pages/loading_page.dart';

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
				'/main-page': (context) => MainPage()
			},
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
		);
	}
}
