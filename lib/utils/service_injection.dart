import 'package:flutter/widgets.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:get_it/get_it.dart';

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
import '../services/notifications/notification_service.dart';
import '../services/notifications/onesignal/onesignal_notification_service.dart';
import '../services/observers/user/user_notifier.dart';
import '../services/plan_keeper_service.dart';
import '../services/plan_repeatability_service.dart';
import '../services/remote_config_provider.dart';
import '../services/remote_storage/firebase_storage_service.dart';
import '../services/remote_storage/remote_storage_provider.dart';
import '../services/task_instance_service.dart';
import '../services/ui_data_aggregator.dart';

Future registerServices(UserNotifier userNotifier, GlobalKey<NavigatorState> navigatorKey, AppRouteObserver routeObserver) {
	// Semi-services needed for context and navigation state sharing
	GetIt.I.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
	GetIt.I.registerSingleton<AppRouteObserver>(routeObserver);

	GetIt.I.registerSingleton<AuthenticationProvider>(AuthenticationProvider.instance);
	GetIt.I.registerSingleton<UserNotifier>(userNotifier);
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
