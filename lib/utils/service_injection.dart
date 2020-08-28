import 'package:flutter/widgets.dart';
import 'package:fokus/services/task_instance_service.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/services/data/db/db_data_repository.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/services/app_config/app_shared_preferences_provider.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/services/plan_keeper_service.dart';
import 'package:fokus/services/auth/authentication_repository.dart';
import 'package:fokus/services/auth/firebase_auth_repository.dart';
import 'package:fokus/services/remote_config_provider.dart';

void initializeServices(RouteObserver<PageRoute> routeObserver) {
	GetIt.I.registerSingleton<AuthenticationRepository>(FirebaseAuthRepository());
	GetIt.I.registerSingleton<RemoteConfigProvider>(RemoteConfigProvider()..initialize());
	GetIt.I.registerSingleton<AppConfigRepository>(AppConfigRepository(AppSharedPreferencesProvider())..initialize());
	GetIt.I.registerSingleton<DataRepository>(DbDataRepository());
	GetIt.I.registerSingleton<PlanRepeatabilityService>(PlanRepeatabilityService());
	GetIt.I.registerSingleton<PlanKeeperService>(PlanKeeperService());
	GetIt.I.registerSingleton<TaskInstanceService>(TaskInstanceService());
	GetIt.I.registerSingleton<RouteObserver<PageRoute>>(routeObserver);
}
