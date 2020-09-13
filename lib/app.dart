import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/auth/caregiver/sign_in/caregiver_sign_in_cubit.dart';
import 'package:fokus/logic/auth/caregiver/sign_up/caregiver_sign_up_cubit.dart';
import 'package:fokus/logic/auth/child/prev_profiles_cubit.dart';
import 'package:fokus/logic/auth/child/sign_in/child_sign_in_cubit.dart';
import 'package:fokus/logic/auth/child/sign_up/child_sign_up_cubit.dart';
import 'package:fokus/logic/plan_cubit.dart';
import 'package:fokus/logic/plan_instance_cubit.dart';
import 'package:fokus/logic/calendar_cubit.dart';
import 'package:fokus/logic/caregiver_panel_cubit.dart';
import 'package:fokus/logic/caregiver_plans_cubit.dart';
import 'package:fokus/logic/child_plans_cubit.dart';
import 'package:fokus/logic/plan_form/plan_form_cubit.dart';
import 'package:fokus/logic/task_instance/task_instance_cubit.dart';
import 'package:fokus/pages/child/calendar_page.dart';

import 'package:fokus/pages/loading_page.dart';
import 'package:fokus/pages/plan_details_page.dart';
import 'package:fokus/pages/roles_page.dart';
import 'package:fokus/pages/notifications_page.dart';
import 'package:fokus/pages/settings_page.dart';
import 'package:fokus/pages/caregiver/auth/caregiver_sign_in_page.dart';
import 'package:fokus/pages/caregiver/auth/caregiver_sign_up_page.dart';
import 'package:fokus/pages/caregiver/awards_page.dart';
import 'package:fokus/pages/caregiver/calendar_page.dart';
import 'package:fokus/pages/caregiver/child_dashboard_page.dart';
import 'package:fokus/pages/caregiver/award_form_page.dart';
import 'package:fokus/pages/caregiver/badge_form_page.dart';
import 'package:fokus/pages/caregiver/panel_page.dart';
import 'package:fokus/pages/caregiver/plan_form_page.dart';
import 'package:fokus/pages/caregiver/plans_page.dart';
import 'package:fokus/pages/caregiver/statistics_page.dart';
import 'package:fokus/pages/caregiver/rating_page.dart';
import 'package:fokus/pages/child/auth/child_profiles_page.dart';
import 'package:fokus/pages/child/auth/child_sign_in_page.dart';
import 'package:fokus/pages/child/awards_page.dart';
import 'package:fokus/pages/child/panel_page.dart';
import 'package:fokus/pages/child/plan_in_progress_page.dart';
import 'package:fokus/pages/child/task_in_progress_page.dart';
import 'package:fokus/pages/child/achievements_page.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/services/instrumentator.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/utils/service_injection.dart';
import 'package:fokus/widgets/page_theme.dart';

void main() {
	WidgetsFlutterBinding.ensureInitialized();
	var navigatorKey = GlobalKey<NavigatorState>();
	var routeObserver = RouteObserver<PageRoute>();
	initializeServices(routeObserver);

	Instrumentator.runAppGuarded(
		BlocProvider<AuthenticationBloc>(
			create: (context) => AuthenticationBloc(),
			child: FokusApp(navigatorKey, routeObserver),
		),
		navigatorKey
	);
}

class FokusApp extends StatelessWidget {
	final GlobalKey<NavigatorState> _navigatorKey;
	final _routeObserver;

  FokusApp(this._navigatorKey, this._routeObserver);

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
			navigatorObservers: [_routeObserver],
			initialRoute: AppPage.loadingPage.name,
			routes: _createRoutes(),

			theme: _createAppTheme(),
			builder: _authenticationGateBuilder,
		);
	}

	Widget _authenticationGateBuilder(BuildContext context, Widget child) {
		return BlocListener<AuthenticationBloc, AuthenticationState>(
			listener: (context, state) {
				var redirectPage = state.status == AuthenticationStatus.authenticated ? state.user.role.panelPage : AppPage.rolesPage;
				_navigatorKey.currentState.pushNamedAndRemoveUntil(redirectPage.name, (route) => false);
			},
			child: child
		);
	}

	Map<String, WidgetBuilder> _createRoutes() {
		var getActiveUser = (BuildContext context) => () => context.bloc<AuthenticationBloc>().state.user;
		var getRoute = (BuildContext context) => ModalRoute.of(context);
		var getParams = (BuildContext context) => getRoute(context).settings.arguments;
		var authBloc = (BuildContext context) => context.bloc<AuthenticationBloc>();
		return {
			AppPage.loadingPage.name: (context) => _createPage(LoadingPage(), context),
			AppPage.rolesPage.name: (context) => _createPage(RolesPage(), context),
      AppPage.notificationsPage.name: (context) => _createPage(NotificationsPage(), context),
			AppPage.settingsPage.name:  (context) => _createPage(SettingsPage(), context),
			AppPage.caregiverSignInPage.name: (context) => _createPage(CaregiverSignInPage(), context, CaregiverSignInCubit()),
			AppPage.caregiverSignUpPage.name: (context) => _createPage(CaregiverSignUpPage(), context, CaregiverSignUpCubit()),
			AppPage.childProfilesPage.name: (context) => _createPage(ChildProfilesPage(), context, PreviousProfilesCubit(authBloc(context), getRoute(context))),
			AppPage.childSignInPage.name: (context) => _createPage(_wrapWithCubit(ChildSignInPage(), ChildSignInCubit(authBloc(context))), context, ChildSignUpCubit(authBloc(context))),
			AppPage.caregiverPanel.name: (context) => _createPage(CaregiverPanelPage(), context, CaregiverPanelCubit(getActiveUser(context), getRoute(context))),
			AppPage.caregiverChildDashboard.name: (context) => _createPage(CaregiverChildDashboardPage(), context),
			AppPage.caregiverPlans.name: (context) => _createPage(CaregiverPlansPage(), context, CaregiverPlansCubit(getActiveUser(context), getRoute(context))),
			AppPage.caregiverCalendar.name: (context) => _createPage(CaregiverCalendarPage(), context, CalendarCubit(getParams(context), getActiveUser(context))),
			AppPage.caregiverPlanForm.name: (context) => _createPage(CaregiverPlanFormPage(), context, PlanFormCubit(getParams(context), getActiveUser(context))),
			AppPage.caregiverAwards.name: (context) => _createPage(CaregiverAwardsPage(), context),
			AppPage.caregiverAwardForm.name: (context) => _createPage(CaregiverAwardFormPage(), context),
			AppPage.caregiverBadgeForm.name: (context) => _createPage(CaregiverBadgeFormPage(), context),
			AppPage.caregiverStatistics.name: (context) => _createPage(CaregiverStatisticsPage(), context),
			AppPage.caregiverRatingPage.name: (context) => _createPage(CaregiverRatingPage(), context),
			AppPage.childPanel.name: (context) => _createPage(ChildPanelPage(), context, ChildPlansCubit(getActiveUser(context), getRoute(context))),
			AppPage.childCalendar.name: (context) => _createPage(ChildCalendarPage(), context, CalendarCubit(getParams(context), getActiveUser(context))),
			AppPage.childAwards.name: (context) => _createPage(ChildAwardsPage(), context),
			AppPage.childAchievements.name: (context) => _createPage(ChildAchievementsPage(), context),
			AppPage.caregiverPlanDetails.name: (context) => _createPage(CaregiverPlanDetailsPage(), context, PlanCubit(getParams(context), getRoute(context))),
			AppPage.childPlanInProgress.name: (context) => _createPage(ChildPlanInProgressPage(), context, PlanInstanceCubit(getParams(context), getRoute(context))),
			AppPage.childTaskInProgress.name: (context) => _createPage(ChildTaskInProgressPage(), context, TaskInstanceCubit(getParams(context), getActiveUser(context)))
		};
	}

	Widget _createPage<CubitType extends Cubit>(Widget page, BuildContext context, [CubitType pageCubit]) {
		if (pageCubit != null)
			page = _wrapWithCubit(page, pageCubit);
		var authState = context.bloc<AuthenticationBloc>().state;
		if (authState.status == AuthenticationStatus.authenticated)
			return PageTheme.parametrizedRoleSection(
				userRole: authState.user.role,
				child: page
			);
		return PageTheme.loginSection(child: page);
	}

	Widget _wrapWithCubit<CubitType extends Cubit>(Widget page, CubitType pageCubit) {
		return BlocProvider<CubitType>(
			create: (context) => pageCubit,
			child: page,
		);
	}

	ThemeData _createAppTheme() {
		return ThemeData(
			primaryColor: AppColors.mainBackgroundColor,
			fontFamily: 'Lato',
			textTheme: TextTheme(
				// Will probably change over time
				headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: AppColors.darkTextColor), // Scaffold/appbar headline
				headline2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppColors.darkTextColor), // Main headline before lists
				headline3: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal, color: AppColors.darkTextColor), //For headers inside list elements
				subtitle2: TextStyle(fontSize: 13.0, fontWeight: FontWeight.normal, color: AppColors.mediumTextColor), // Little subtitle for headline2
				bodyText1: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal, color: AppColors.lightTextColor), // Classic body text on light background
				bodyText2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal, color: AppColors.darkTextColor), // Classic body text on color
				button: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.lightTextColor) // (Almost always white) button text
			),
		);
	}
	
}
