import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/logic/caregiver_panel/caregiver_panel_cubit.dart';
import 'package:fokus/logic/caregiver_plans/caregiver_plans_cubit.dart';
import 'package:fokus/logic/child_plans/child_plans_cubit.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/pages/caregiver/awards_page.dart';
import 'package:fokus/pages/caregiver/panel_page.dart';
import 'package:fokus/pages/caregiver/plans_page.dart';
import 'package:fokus/pages/caregiver/statistics_page.dart';
import 'package:fokus/pages/child/achievements_page.dart';
import 'package:fokus/pages/child/awards_page.dart';
import 'package:fokus/pages/child/panel_page.dart';
import 'package:fokus/pages/notifications_page.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/services/instrumentator.dart';
import 'package:fokus/utils/cubit_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/pages/loading_page.dart';
import 'package:fokus/pages/roles_page.dart';
import 'package:fokus/widgets/page_theme.dart';
import 'package:fokus/model/app_page.dart';

void main() {
	var navigatorKey = GlobalKey<NavigatorState>();
	Instrumentator.runAppGuarded(
		BlocProvider<ActiveUserCubit>(
			create: (context) => ActiveUserCubit(),
			child: FokusApp(navigatorKey),
		),
		navigatorKey
	);
}

class FokusApp extends StatelessWidget {
	final GlobalKey<NavigatorState> _navigatorKey;

  FokusApp(this._navigatorKey);

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
			navigatorKey: _navigatorKey,
			initialRoute: AppPage.loadingPage.name,
			routes: _createRoutes(),
			theme: _createAppTheme(),
		);
	}

	Map<String, WidgetBuilder> _createRoutes() {
		var activeUser = (context) => BlocProvider.of<ActiveUserCubit>(context);
		return {
			AppPage.loadingPage.name: (context) => PageTheme.loginSection(child: LoadingPage()),
			AppPage.rolesPage.name: (context) => PageTheme.loginSection(child: RolesPage()),
      AppPage.notificationsPage.name: (context) => _wrapAppPage(UserRole.caregiver, NotificationsPage()), // TODO userrole could be of any type in some pages - support this
			AppPage.caregiverPanel.name: (context) => _wrapAppPage(UserRole.caregiver, CaregiverPanelPage(), CaregiverPanelCubit(activeUser(context))),
			AppPage.caregiverPlans.name: (context) => _wrapAppPage(UserRole.caregiver, CaregiverPlansPage(), CaregiverPlansCubit(activeUser(context))),
			AppPage.caregiverAwards.name: (context) => _wrapAppPage(UserRole.caregiver, CaregiverAwardsPage()),
			AppPage.caregiverStatistics.name: (context) => _wrapAppPage(UserRole.caregiver, CaregiverStatisticsPage()),
			AppPage.childPanel.name: (context) => _wrapAppPage(UserRole.child, ChildPanelPage(), ChildPlansCubit(activeUser(context))),
			AppPage.childAwards.name: (context) => _wrapAppPage(UserRole.child, ChildAwardsPage()),
			AppPage.childAchievements.name: (context) => _wrapAppPage(UserRole.child, ChildAchievementsPage()),
		};
	}

	Widget _wrapAppPage<CubitType extends Cubit>(UserRole userRole, Widget page, [CubitType pageCubit]) {
		if (pageCubit != null)
			page = BlocProvider<CubitType>(
				create: (context) => pageCubit,
				child: page,
			);
		return navigateOnState<ActiveUserCubit, ActiveUserState, NoActiveUser>(
			navigation: (navigator) => navigator.pushNamedAndRemoveUntil(AppPage.rolesPage.name, (_) => false),
			child: PageTheme.parametrizedRoleSection(
				userRole: userRole,
				child: page
			)
		);
	}

	ThemeData _createAppTheme() {
		return ThemeData(
			primaryColor: AppColors.mainBackgroundColor,
			fontFamily: 'Lato',
			textTheme: TextTheme(
				// Will probably change over time
				headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: AppColors.darkTextColor), // Scaffold/appbar headline
				headline2: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: AppColors.darkTextColor), // Main headline before lists
				headline3: TextStyle(fontSize: 21.0, fontWeight: FontWeight.normal, color: AppColors.darkTextColor), //For headers inside list elements
				subtitle2: TextStyle(fontSize: 13.0, fontWeight: FontWeight.normal, color: AppColors.mediumTextColor), // Little subtitle for headline2
				bodyText1: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal, color: AppColors.lightTextColor), // Classic body text on light background
				bodyText2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal, color: AppColors.darkTextColor), // Classic body text on color
				button: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.lightTextColor) // (Almost always white) button text
			),
		);
	}
}
