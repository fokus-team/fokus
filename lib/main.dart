import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:round_spot/round_spot.dart' as round_spot;

import 'logic/caregiver/auth/sign_in/caregiver_sign_in_cubit.dart';
import 'logic/caregiver/auth/sign_up/caregiver_sign_up_cubit.dart';
import 'logic/caregiver/caregiver_awards_cubit.dart';
import 'logic/caregiver/caregiver_currencies_cubit.dart';
import 'logic/caregiver/caregiver_friends_cubit.dart';
import 'logic/caregiver/caregiver_panel_cubit.dart';
import 'logic/caregiver/caregiver_plans_cubit.dart';
import 'logic/caregiver/child_dashboard/child_dashboard_cubit.dart';
import 'logic/caregiver/child_dashboard/dashboard_achievements_cubit.dart';
import 'logic/caregiver/child_dashboard/dashboard_plans_cubit.dart';
import 'logic/caregiver/child_dashboard/dashboard_rewards_cubit.dart';
import 'logic/caregiver/forms/badge_form_cubit.dart';
import 'logic/caregiver/forms/plan/plan_form_cubit.dart';
import 'logic/caregiver/forms/reward_form_cubit.dart';
import 'logic/caregiver/tasks_evaluation_cubit.dart';
import 'logic/child/auth/saved_child_profiles_cubit.dart';
import 'logic/child/auth/sign_in/child_sign_in_cubit.dart';
import 'logic/child/auth/sign_up/child_sign_up_cubit.dart';
import 'logic/child/child_panel_cubit.dart';
import 'logic/child/child_rewards_cubit.dart';
import 'logic/child/task_completion/task_completion_cubit.dart';
import 'logic/common/auth_bloc/authentication_bloc.dart';
import 'logic/common/calendar_cubit.dart';
import 'logic/common/plan_cubit.dart';
import 'logic/common/plan_instance_cubit.dart';
import 'logic/common/settings/account_delete/account_delete_cubit.dart';
import 'logic/common/settings/locale_cubit.dart';
import 'logic/common/settings/name_change/name_change_cubit.dart';
import 'logic/common/settings/password_change/password_change_cubit.dart';
import 'model/app_error_type.dart';
import 'model/db/user/user.dart';
import 'model/db/user/user_role.dart';
import 'model/navigation/child_dashboard_params.dart';
import 'model/navigation/plan_form_params.dart';
import 'model/navigation/plan_instance_params.dart';
import 'model/navigation/report_form_params.dart';
import 'model/navigation/task_form_params.dart';
import 'model/navigation/task_in_progress_params.dart';
import 'model/ui/app_page.dart';
import 'model/ui/auth/password_change_type.dart';
import 'pages/caregiver/auth/caregiver_sign_in_page.dart';
import 'pages/caregiver/auth/caregiver_sign_up_page.dart';
import 'pages/caregiver/awards_page.dart';
import 'pages/caregiver/calendar_page.dart';
import 'pages/caregiver/child_dashboard_page.dart';
import 'pages/caregiver/currencies_page.dart';
import 'pages/caregiver/forms/badge_form_page.dart';
import 'pages/caregiver/forms/plan_form_page.dart';
import 'pages/caregiver/forms/report_form_page.dart';
import 'pages/caregiver/forms/reward_form_page.dart';
import 'pages/caregiver/forms/task_form_page.dart';
import 'pages/caregiver/friend_plans_page.dart';
import 'pages/caregiver/panel_page.dart';
import 'pages/caregiver/plans_page.dart';
import 'pages/caregiver/rating_page.dart';
import 'pages/child/achievements_page.dart';
import 'pages/child/auth/child_profiles_page.dart';
import 'pages/child/auth/child_sign_in_page.dart';
import 'pages/child/calendar_page.dart';
import 'pages/child/panel_page.dart';
import 'pages/child/rewards_page.dart';
import 'pages/child/task_in_progress_page.dart';
import 'pages/common/error_page.dart';
import 'pages/common/loading_page.dart';
import 'pages/common/notifications_page.dart';
import 'pages/common/plan_details_page.dart';
import 'pages/common/plan_instance_details_page.dart';
import 'pages/common/roles_page.dart';
import 'pages/common/settings_page.dart';
import 'services/analytics_service.dart';
import 'services/app_locales.dart';
import 'services/app_route_observer.dart';
import 'services/locale_service.dart';
import 'services/observers/current_locale_observer.dart';
import 'utils/app_initialization.dart';
import 'utils/bloc_utils.dart';
import 'utils/ui/theme_config.dart';
import 'widgets/page_theme.dart';


void main() async {
	await initializeComponents();

	bootstrapApplication(
		app: FokusApp(
			navigatorKey: GetIt.I<GlobalKey<NavigatorState>>(),
			routeObserver: GetIt.I<AppRouteObserver>(),
			pageObserver: GetIt.I<AnalyticsService>().pageObserver
		),
	);
}

class FokusApp extends StatefulWidget {
	final GlobalKey<NavigatorState> navigatorKey;
	final RouteObserver<PageRoute> routeObserver;
	final FirebaseAnalyticsObserver pageObserver;

  const FokusApp({required this.navigatorKey, required this.routeObserver, required this.pageObserver});

  @override
  _FokusAppState createState() => _FokusAppState();
}

class _FokusAppState extends State<FokusApp> implements CurrentLocaleObserver {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Fokus',
			localizationsDelegates: const [
				AppLocales.delegate,
				GlobalMaterialLocalizations.delegate,
				GlobalWidgetsLocalizations.delegate,
				GlobalCupertinoLocalizations.delegate,
			],
			supportedLocales: AppLocalesDelegate.supportedLocales,
			localeListResolutionCallback: LocaleService.localeSelector,

			navigatorKey: widget.navigatorKey,
			navigatorObservers: [
				widget.routeObserver,
				widget.pageObserver,
				round_spot.Observer()
			],
			initialRoute: AppPage.loadingPage.name,
			routes: _createRoutes(),
			onGenerateRoute: _onGenerateRoute,

			themeMode: ThemeMode.light,
			theme: _createAppTheme(),
			builder: _authenticationGateBuilder
		);
	}

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
		getActiveUser(BuildContext context) => () => BlocProvider.of<AuthenticationBloc>(context).state.user!;
		var getRoute = ModalRoute.of;
		getParams(BuildContext context) => getRoute(context)?.settings.arguments;
		authBloc(BuildContext context) => BlocProvider.of<AuthenticationBloc>(context);

		var routesWithFadeTransition = <String, RoutePageBuilder>{
			// Caregiver pages
			AppPage.caregiverPanel.name: (context, _, __) => _createPage(
				withCubit(CaregiverPanelPage(), CaregiverFriendsCubit(getActiveUser(context), authBloc(context))),
				context,
				cubit: CaregiverPanelCubit(getRoute(context)!)
			),
			AppPage.caregiverPlans.name: (context, _, __) => _createPage(CaregiverPlansPage(), context, cubit: CaregiverPlansCubit(
				getRoute(context)!,
				getParams(context) as MapEntry<mongo.ObjectId, String>?
			)),
			AppPage.caregiverAwards.name: (context, _, __) => _createPage(CaregiverAwardsPage(), context, cubit: CaregiverAwardsCubit(getRoute(context))),
			// Child pages
			AppPage.childPanel.name: (context, _, __) =>  _createPage(ChildPanelPage(), context, cubit: ChildPanelCubit(getRoute(context)!)),
			AppPage.childRewards.name: (context, _, __) =>  _createPage(ChildRewardsPage(), context, cubit: ChildRewardsCubit(getRoute(context)!)),
			AppPage.childAchievements.name: (context, _, __) =>  _createPage(ChildAchievementsPage(), context)
		};

		if(routesWithFadeTransition.containsKey(settings.name))
			return PageRouteBuilder(
				pageBuilder: routesWithFadeTransition[settings.name]!,
				settings: settings,
				transitionsBuilder: (context, animation, secondaryAnimation, child) {
					return FadeTransition(
						opacity: animation,
						child: child
					);
				}
			);
		return null;
  }

	Widget _authenticationGateBuilder(BuildContext context, Widget? child) {
		return BlocListener<AuthenticationBloc, AuthenticationState>(
			listenWhen: (oldState, newState) => oldState.status != newState.status,
			listener: (context, state) {
				var redirectPage = state.signedIn ? state.user!.role!.panelPage : AppPage.rolesPage;
				widget.navigatorKey.currentState?.pushNamedAndRemoveUntil(redirectPage.name, (route) => false);
			},
			child: child
		);
	}

	Map<String, WidgetBuilder> _createRoutes() {
		getActiveUser(BuildContext context) => () => BlocProvider.of<AuthenticationBloc>(context).state.user!;
		var getRoute = ModalRoute.of;
		getParams(BuildContext context) => getRoute(context)?.settings.arguments;
		authBloc(BuildContext context) => BlocProvider.of<AuthenticationBloc>(context);
		accountManaging(BuildContext context, Widget page, [User? user]) => withCubit(
			withCubit(page, NameChangeCubit(getActiveUser(context), authBloc(context), user)),
			AccountDeleteCubit(getActiveUser(context), user)
		);

		return {
			AppPage.loadingPage.name: (context) => _createPage(LoadingPage(), context),
			AppPage.errorPage.name: (context) => _createPage(ErrorPage(getParams(context) as AppErrorType), context, section: AppPageSection.login),
			AppPage.rolesPage.name: (context) => _createPage(RolesPage(), context),
      AppPage.notificationsPage.name: (context) => _createPage(NotificationsPage(), context),
			AppPage.settingsPage.name:  (context) => _createPage(
				withCubit(
					accountManaging(context, SettingsPage()),
					LocaleCubit(getActiveUser(context), authBloc(context))
				), context, cubit: PasswordChangeCubit(PasswordChangeType.change)
			),
			AppPage.caregiverSignInPage.name: (context) => _createPage(CaregiverSignInPage(), context, cubit: CaregiverSignInCubit(getParams(context) as String?)),
			AppPage.caregiverSignUpPage.name: (context) => _createPage(CaregiverSignUpPage(), context, cubit: CaregiverSignUpCubit()),
			AppPage.childProfilesPage.name: (context) => _createPage(ChildProfilesPage(), context, cubit: SavedChildProfilesCubit(authBloc(context), getRoute(context)!)),
			AppPage.childSignInPage.name: (context) => _createPage(
				withCubit(ChildSignInPage(), ChildSignInCubit(authBloc(context))),
				context,
				cubit: ChildSignUpCubit(authBloc(context)),
				section: AppPageSection.login
			),
			AppPage.caregiverChildDashboard.name: (context) {
				var plans = DashboardPlansCubit(getRoute(context)!);
				var rewards = DashboardRewardsCubit(getRoute(context)!);
				var achievements = DashboardAchievementsCubit(getRoute(context)!);
			  return _createPage(
					withCubit(withCubit(withCubit(accountManaging(context, CaregiverChildDashboardPage(getParams(context) as ChildDashboardParams),
							(getParams(context) as ChildDashboardParams).childCard.child), plans), achievements), rewards),
					context, cubit: ChildDashboardCubit(getParams(context) as ChildDashboardParams, getRoute(context)!, plans, rewards, achievements)
				);
			},
			AppPage.caregiverCalendar.name: (context) => _createPage(CaregiverCalendarPage(), context, cubit: CalendarCubit(getParams(context) as mongo.ObjectId?, getActiveUser(context))),
			AppPage.caregiverPlanForm.name: (context) => _createPage(CaregiverPlanFormPage(), context, cubit: PlanFormCubit(getParams(context)  as PlanFormParams?, getActiveUser(context))),
			AppPage.caregiverTaskForm.name: (context) => _createPage(TaskFormPage(getParams(context) as TaskFormParams), context),
			AppPage.caregiverRewardForm.name: (context) => _createPage(CaregiverRewardFormPage(), context, cubit: RewardFormCubit(getParams(context) as mongo.ObjectId?, getRoute(context)!)),
			AppPage.caregiverBadgeForm.name: (context) => _createPage(CaregiverBadgeFormPage(), context, cubit: BadgeFormCubit(authBloc(context), getRoute(context)!)),
			AppPage.caregiverRatingPage.name: (context) => _createPage(CaregiverRatingPage(), context, cubit: TasksEvaluationCubit(getRoute(context)!)),
			AppPage.caregiverReportForm.name: (context) => _createPage(ReportFormPage(getParams(context) as ReportFormParams), context),
			AppPage.caregiverCurrencies.name: (context) => _createPage(CaregiverCurrenciesPage(), context, cubit: CaregiverCurrenciesCubit(getRoute(context)!, authBloc(context))),
			AppPage.caregiverFriendPlans.name: (context) => _createPage(
				withCubit(CaregiverFriendPlansPage(), CaregiverFriendsCubit(getActiveUser(context), authBloc(context))),
				context,
				cubit: CaregiverPlansCubit(getRoute(context)!, getParams(context) as MapEntry<mongo.ObjectId, String>?)
			),
			AppPage.planDetails.name: (context) => _createPage(PlanDetailsPage(), context, cubit: PlanCubit(getParams(context) as mongo.ObjectId, getRoute(context)!)),
			AppPage.childCalendar.name: (context) => _createPage(ChildCalendarPage(), context, cubit: CalendarCubit(getParams(context) as mongo.ObjectId, getActiveUser(context))),
			AppPage.planInstanceDetails.name: (context) => _createPage(
				PlanInstanceDetailsPage(getParams(context) as PlanInstanceParams),
				context,
				cubit: PlanInstanceCubit(getParams(context) as PlanInstanceParams, getRoute(context)!)
			),
			AppPage.childTaskInProgress.name: (context) => _createPage(ChildTaskInProgressPage(), context, cubit: TaskCompletionCubit(getParams(context) as TaskInProgressParams, getRoute(context)!))
		};
	}

	Widget _createPage<CubitType extends Cubit>(Widget page, BuildContext context, {CubitType? cubit, AppPageSection? section}) {
		if (cubit != null)
			page = withCubit(page, cubit);
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
