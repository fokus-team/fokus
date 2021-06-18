import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:round_spot/round_spot.dart' as round_spot;

import '../logic/common/auth_bloc/authentication_bloc.dart';
import '../services/analytics_service.dart';
import '../services/app_config/app_config_repository.dart';
import '../services/app_config/app_shared_preferences_provider.dart';
import '../services/app_route_observer.dart';
import '../services/data/data_repository.dart';
import '../services/data/db/db_data_repository.dart';
import '../services/instrumentator.dart';
import '../services/links/firebase_link_service.dart';
import '../services/links/link_service.dart';
import '../services/locale_service.dart';
import '../services/model_helpers/plan_repeatability_service.dart';
import '../services/model_helpers/task_instance_service.dart';
import '../services/model_helpers/ui_data_aggregator.dart';
import '../services/notifications/notification_service.dart';
import '../services/notifications/onesignal/onesignal_notification_service.dart';
import '../services/observers/user/authenticated_user_notifier.dart';
import '../services/observers/user/user_notifier.dart';
import '../services/plan_keeper_service.dart';
import '../services/remote_config_provider.dart';
import '../services/remote_storage/firebase_storage_service.dart';
import '../services/remote_storage/remote_storage_provider.dart';

Future registerServices() {
	// Semi-services needed for context and navigation state sharing
	GetIt.I.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());
	GetIt.I.registerSingleton<AppRouteObserver>(AppRouteObserver());

	GetIt.I.registerSingleton<AuthenticationProvider>(AuthenticationProvider.instance);
	GetIt.I.registerSingleton<UserNotifier>(AuthenticatedUserNotifier());
	GetIt.I.registerSingletonAsync<AppConfigRepository>(() => AppConfigRepository(AppSharedPreferencesProvider()).initialize());
	GetIt.I.registerSingleton<DataRepository>(DbDataRepository());
	GetIt.I.registerSingleton<PlanRepeatabilityService>(PlanRepeatabilityService());
	GetIt.I.registerSingleton<PlanKeeperService>(PlanKeeperService());
	GetIt.I.registerSingleton<UIDataAggregator>(UIDataAggregator());
	GetIt.I.registerSingleton<TaskInstanceService>(TaskInstanceService());
	GetIt.I.registerSingleton<NotificationService>(OneSignalNotificationService());
	GetIt.I.registerSingleton<LocaleService>(LocaleService());
	GetIt.I.registerSingleton<AnalyticsService>(AnalyticsService());
	GetIt.I.registerSingleton<Instrumentator>(Instrumentator());
	GetIt.I.registerSingleton<LinkService>(FirebaseDynamicLinkService());
	GetIt.I.registerSingleton<RemoteStorageProvider>(FirebaseStorageService());
	GetIt.I.registerSingletonAsync<RemoteConfigProvider>(() => RemoteConfigProvider().initialize());

	return GetIt.I.allReady();
}

Future initializeComponents() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Firebase.initializeApp();
	return registerServices();
}

void bootstrapApplication({required Widget app}) async {
	GetIt.I<AnalyticsService>().logAppOpen();
	GetIt.I<Instrumentator>().runAppGuarded(
		BlocProvider<AuthenticationBloc>(
			create: (context) => AuthenticationBloc(GetIt.I<UserNotifier>() as AuthenticatedUserNotifier),
			child: await initializeRoundSpot(
				child: app,
			),
		),
	);
}

Future<Widget> initializeRoundSpot({required Widget child}) async {
	var configMap = (await GetIt.I.getAsync<RemoteConfigProvider>()).roundSpotConfig;
	var config = configMap.isNotEmpty ? round_spot.Config.fromJson(json.decode(configMap)) : round_spot.Config();

	return round_spot.initialize(
		child: child,
		config: config,
		dataCallback: GetIt.I<RemoteStorageProvider>().uploadRSData,
		loggingLevel: foundation.kReleaseMode ? round_spot.LogLevel.off : round_spot.LogLevel.warning
	);
}
