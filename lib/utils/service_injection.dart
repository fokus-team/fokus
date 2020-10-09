import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:fokus_auth/fokus_auth.dart';

import 'package:fokus/services/data/db/db_data_repository.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/services/app_config/app_shared_preferences_provider.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/services/plan_keeper_service.dart';
import 'package:fokus/services/task_instance_service.dart';
import 'package:fokus/services/notifications/onesignal/onesignal_notification_service.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/locale_provider.dart';

Future registerServices(GlobalKey<NavigatorState> navigatorKey, RouteObserver<PageRoute> routeObserver) {
	// Semi-services needed for context and navigation state sharing
	GetIt.I.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
	GetIt.I.registerSingleton<RouteObserver<PageRoute>>(routeObserver);

	GetIt.I.registerSingleton<AuthenticationProvider>(AuthenticationProvider.instance);
	GetIt.I.registerSingletonAsync<AppConfigRepository>(() => AppConfigRepository(AppSharedPreferencesProvider()).initialize());
	GetIt.I.registerSingleton<DataRepository>(DbDataRepository());
	GetIt.I.registerSingleton<PlanRepeatabilityService>(PlanRepeatabilityService());
	GetIt.I.registerSingleton<PlanKeeperService>(PlanKeeperService());
	GetIt.I.registerSingleton<TaskInstanceService>(TaskInstanceService());
	GetIt.I.registerSingleton<NotificationService>(OneSignalNotificationService());
	GetIt.I.registerSingleton<LocaleService>(LocaleService());

	return GetIt.I.allReady();
}
