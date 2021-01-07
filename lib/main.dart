import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fokus/logic/caregiver/caregiver_friends_cubit.dart';
import 'package:fokus/logic/caregiver/child_dashboard/child_dashboard_cubit.dart';

import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/caregiver/auth/sign_in/caregiver_sign_in_cubit.dart';
import 'package:fokus/logic/caregiver/auth/sign_up/caregiver_sign_up_cubit.dart';
import 'package:fokus/logic/child/auth/prev_profiles_cubit.dart';
import 'package:fokus/logic/child/auth/sign_in/child_sign_in_cubit.dart';
import 'package:fokus/logic/child/auth/sign_up/child_sign_up_cubit.dart';
import 'package:fokus/logic/caregiver/caregiver_awards_cubit.dart';
import 'package:fokus/logic/caregiver/caregiver_currencies_cubit.dart';
import 'package:fokus/logic/common/plan_cubit.dart';
import 'package:fokus/logic/common/plan_instance_cubit.dart';
import 'package:fokus/logic/common/calendar_cubit.dart';
import 'package:fokus/logic/caregiver/caregiver_panel_cubit.dart';
import 'package:fokus/logic/caregiver/caregiver_plans_cubit.dart';
import 'package:fokus/logic/child/child_panel_cubit.dart';
import 'package:fokus/logic/child/child_rewards_cubit.dart';
import 'package:fokus/logic/caregiver/plan_form/plan_form_cubit.dart';
import 'package:fokus/logic/common/settings/account_delete/account_delete_cubit.dart';
import 'package:fokus/logic/common/settings/name_change/name_change_cubit.dart';
import 'package:fokus/logic/common/settings/password_change/password_change_cubit.dart';
import 'package:fokus/logic/common/settings/locale_cubit.dart';
import 'package:fokus/logic/child/task_instance/task_instance_cubit.dart';
import 'package:fokus/logic/caregiver/reward_form/reward_form_cubit.dart';
import 'package:fokus/logic/caregiver/badge_form/badge_form_cubit.dart';
import 'package:fokus/logic/caregiver/tasks_evaluation/tasks_evaluation_cubit.dart';
import 'package:fokus/model/ui/auth/password_change_type.dart';
import 'package:fokus/pages/child/calendar_page.dart';

import 'package:fokus/pages/loading_page.dart';
import 'package:fokus/pages/plan/plan_details_page.dart';
import 'package:fokus/pages/roles_page.dart';
import 'package:fokus/pages/notifications_page.dart';
import 'package:fokus/pages/settings_page.dart';
import 'package:fokus/pages/caregiver/auth/caregiver_sign_in_page.dart';
import 'package:fokus/pages/caregiver/auth/caregiver_sign_up_page.dart';
import 'package:fokus/pages/caregiver/awards_page.dart';
import 'package:fokus/pages/caregiver/calendar_page.dart';
import 'package:fokus/pages/caregiver/child_dashboard_page.dart';
import 'package:fokus/pages/caregiver/forms/reward_form_page.dart';
import 'package:fokus/pages/caregiver/forms/badge_form_page.dart';
import 'package:fokus/pages/caregiver/panel_page.dart';
import 'package:fokus/pages/caregiver/forms/plan_form_page.dart';
import 'package:fokus/pages/caregiver/plans_page.dart';
import 'package:fokus/pages/caregiver/rating_page.dart';
import 'package:fokus/pages/caregiver/currencies_page.dart';
import 'package:fokus/pages/caregiver/friend_plans_page.dart';
import 'package:fokus/pages/child/auth/child_profiles_page.dart';
import 'package:fokus/pages/child/auth/child_sign_in_page.dart';
import 'package:fokus/pages/child/rewards_page.dart';
import 'package:fokus/pages/child/panel_page.dart';
import 'package:fokus/pages/plan/plan_instance_details_page.dart';
import 'package:fokus/pages/child/task_in_progress_page.dart';
import 'package:fokus/pages/child/achievements_page.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/services/instrumentator.dart';
import 'package:fokus/services/locale_provider.dart';
import 'package:fokus/services/observers/current_locale_observer.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/utils/service_injection.dart';
import 'package:fokus/utils/bloc_utils.dart';
import 'package:fokus/widgets/page_theme.dart';
import 'package:get_it/get_it.dart';
import 'model/ui/plan/ui_plan_instance.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Firebase.initializeApp();
	var navigatorKey = GlobalKey<NavigatorState>();
	var routeObserver = RouteObserver<PageRoute>();
	await registerServices(navigatorKey, routeObserver);

	GetIt.I<Instrumentator>().runAppGuarded(
		BlocProvider<AuthenticationBloc>(
			create: (context) => AuthenticationBloc(),
			child: FokusApp(navigatorKey, routeObserver),
		)
	);
}

class FokusApp extends StatefulWidget {
	final GlobalKey<NavigatorState> _navigatorKey;
	final _routeObserver;

  FokusApp(this._navigatorKey, this._routeObserver);

  @override
  _FokusAppState createState() => _FokusAppState();
}

class _FokusAppState extends State<FokusApp> implements CurrentLocaleObserver {


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
			supportedLocales: AppLocalesDelegate.supportedLocales,
			localeListResolutionCallback: LocaleService.localeSelector,

			navigatorKey: widget._navigatorKey,
			navigatorObservers: [widget._routeObserver],
			initialRoute: AppPage.loadingPage.name,
			routes: _createRoutes(),
			onGenerateRoute: _onGenerateRoute,

			themeMode: ThemeMode.light,
			theme: _createAppTheme(),
			builder: _authenticationGateBuilder
		);
	}

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
		var getActiveUser = (BuildContext context) => () => BlocProvider.of<AuthenticationBloc>(context).state.user;
		var getRoute = (BuildContext context) => ModalRoute.of(context);
		var getParams = (BuildContext context) => getRoute(context).settings.arguments;
		var authBloc = (BuildContext context) => BlocProvider.of<AuthenticationBloc>(context);

		Map<String, Function(BuildContext, Animation<double>, Animation<double>)> routesWithFadeTransition = {
			// Caregiver pages
			AppPage.caregiverPanel.name: (context, _, __) => _createPage(withCubit(CaregiverPanelPage(), CaregiverFriendsCubit(getActiveUser(context), authBloc(context))), context, CaregiverPanelCubit(getActiveUser(context), getRoute(context))),
			AppPage.caregiverPlans.name: (context, _, __) => _createPage(CaregiverPlansPage(), context, CaregiverPlansCubit(getActiveUser(context), getRoute(context), getParams(context))),
			AppPage.caregiverAwards.name: (context, _, __) => _createPage(CaregiverAwardsPage(), context, CaregiverAwardsCubit(getActiveUser(context), getRoute(context))),
			// Child pages
			AppPage.childPanel.name: (context, _, __) =>  _createPage(ChildPanelPage(), context, ChildPanelCubit(getActiveUser(context), getRoute(context))),
			AppPage.childRewards.name: (context, _, __) =>  _createPage(ChildRewardsPage(), context, ChildRewardsCubit(getActiveUser(context), getRoute(context))),
			AppPage.childAchievements.name: (context, _, __) =>  _createPage(ChildAchievementsPage(), context)
		};

		if(routesWithFadeTransition.containsKey(settings.name))
			return PageRouteBuilder(
				pageBuilder: routesWithFadeTransition[settings.name],
				transitionsBuilder: (context, animation, secondaryAnimation, child) {
					return FadeTransition(
						opacity: animation,
						child: child
					);
				}
			);
		return null;
  }

	Widget _authenticationGateBuilder(BuildContext context, Widget child) {
		return BlocListener<AuthenticationBloc, AuthenticationState>(
			listenWhen: (oldState, newState) => oldState.status != newState.status,
			listener: (context, state) {
				var redirectPage = state.status == AuthenticationStatus.authenticated ? state.user.role.panelPage : AppPage.rolesPage;
				widget._navigatorKey.currentState.pushNamedAndRemoveUntil(redirectPage.name, (route) => false);
			},
			child: child
		);
	}

	Map<String, WidgetBuilder> _createRoutes() {
		var getActiveUser = (BuildContext context) => () => BlocProvider.of<AuthenticationBloc>(context).state.user;
		var getRoute = (BuildContext context) => ModalRoute.of(context);
		var getParams = (BuildContext context) => getRoute(context).settings.arguments;
		var authBloc = (BuildContext context) => BlocProvider.of<AuthenticationBloc>(context);
		var accountManaging = (BuildContext context, Widget page) => withCubit(
			withCubit(page, NameChangeCubit(getActiveUser(context), authBloc(context), getParams(context))),
			AccountDeleteCubit(getActiveUser(context), getParams(context))
		);
		return {
			AppPage.loadingPage.name: (context) => _createPage(LoadingPage(), context),
			AppPage.rolesPage.name: (context) => _createPage(RolesPage(), context),
      AppPage.notificationsPage.name: (context) => _createPage(NotificationsPage(), context),
			AppPage.settingsPage.name:  (context) => _createPage(
				withCubit(
					accountManaging(context, SettingsPage()),
					LocaleCubit(getActiveUser(context), authBloc(context))
				), context, PasswordChangeCubit(PasswordChangeType.change)
			),
			AppPage.caregiverSignInPage.name: (context) => _createPage(CaregiverSignInPage(), context, CaregiverSignInCubit(getParams(context))),
			AppPage.caregiverSignUpPage.name: (context) => _createPage(CaregiverSignUpPage(), context, CaregiverSignUpCubit()),
			AppPage.childProfilesPage.name: (context) => _createPage(ChildProfilesPage(), context, PreviousProfilesCubit(authBloc(context), getRoute(context))),
			AppPage.childSignInPage.name: (context) => _createPage(withCubit(ChildSignInPage(), ChildSignInCubit(authBloc(context))), context, ChildSignUpCubit(authBloc(context)), AppPageSection.login),

			AppPage.caregiverChildDashboard.name: (context) => _createPage(
				accountManaging(context, CaregiverChildDashboardPage(getParams(context))),
				context, ChildDashboardCubit(getParams(context), getActiveUser(context), getRoute(context))
			),
			AppPage.caregiverCalendar.name: (context) => _createPage(CaregiverCalendarPage(), context, CalendarCubit(getParams(context), getActiveUser(context))),
			AppPage.caregiverPlanForm.name: (context) => _createPage(CaregiverPlanFormPage(), context, PlanFormCubit((getParams(context) as Map)["type"], getActiveUser(context), (getParams(context) as Map)["date"])),
			AppPage.caregiverRewardForm.name: (context) => _createPage(CaregiverRewardFormPage(), context, RewardFormCubit(getParams(context), getActiveUser(context))),
			AppPage.caregiverBadgeForm.name: (context) => _createPage(CaregiverBadgeFormPage(), context, BadgeFormCubit(getParams(context), getActiveUser(context), authBloc(context))),
			AppPage.caregiverRatingPage.name: (context) => _createPage(CaregiverRatingPage(), context, TasksEvaluationCubit(getRoute(context), getActiveUser(context))),
			AppPage.caregiverCurrencies.name: (context) => _createPage(CaregiverCurrenciesPage(), context, CaregiverCurrenciesCubit(getActiveUser(context), getActiveUser(context), authBloc(context))),
			AppPage.caregiverFriendPlans.name: (context) => _createPage(withCubit(CaregiverFriendPlansPage(), CaregiverFriendsCubit(getActiveUser(context), authBloc(context))), context, CaregiverPlansCubit(getActiveUser(context), getRoute(context), getParams(context))),
			AppPage.planDetails.name: (context) => _createPage(PlanDetailsPage(), context, PlanCubit(getParams(context), getRoute(context))),

			AppPage.childCalendar.name: (context) => _createPage(ChildCalendarPage(), context, CalendarCubit(getParams(context), getActiveUser(context))),
			AppPage.planInstanceDetails.name: (context) => _createPage(PlanInstanceDetailsPage(getParams(context)), context, PlanInstanceCubit(((getParams(context) as Map<String, dynamic>)['plan'] as UIPlanInstance), getRoute(context))),
			AppPage.childTaskInProgress.name: (context) => _createPage(ChildTaskInProgressPage(), context, TaskInstanceCubit((getParams(context) as Map)["TaskId"], getActiveUser(context), (getParams(context) as Map)["UIPlanInstance"]))
		};
	}

	Widget _createPage<CubitType extends Cubit>(Widget page, BuildContext context, [CubitType pageCubit, AppPageSection section]) {
		if (pageCubit != null)
			page = withCubit(page, pageCubit);
		return PageTheme.parametrizedSection(
			authState: BlocProvider.of<AuthenticationBloc>(context).state,
			section: section,
			child: page
		);
	}

	ThemeData _createAppTheme() {
		return ThemeData(
			brightness: Brightness.light,
			primaryColor: AppColors.mainBackgroundColor,
			fontFamily: 'Lato',
			textTheme: TextTheme(
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

	@override
	void onLocaleSet(Locale locale) => setState(() {});

	@override
  void initState() {
		AppLocales.instance.observeLocaleChanges(this);
		super.initState();
  }
}
