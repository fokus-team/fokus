import 'package:cubit/cubit.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/services/data/db_data_repository.dart';
import 'package:fokus/services/remote_config_provider.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/services/app_config/app_shared_preferences_provider.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';

import 'app_init_state.dart';

class AppInitCubit extends Cubit<AppInitState> {
	var _provider = GetIt.instance;

	AppInitCubit() : super(AppInitInProgress()) {
		_provider.registerSingleton<RemoteConfigProvider>(RemoteConfigProvider());
		_provider.registerSingleton<AppConfigRepository>(AppConfigRepository(AppSharedPreferencesProvider())..initialize());
		_provider.registerSingleton<DataRepository>(DbDataRepository());
		_provider.registerSingleton<PlanRepeatabilityService>(PlanRepeatabilityService());
		initializeApp();
	}

	void initializeApp() async {
		// TODO Differentiate between no internet connection and db access error

		await _provider<RemoteConfigProvider>().initialize().then(
			(_) => _provider<DataRepository>().initialize()
		).then((_) => emit(AppInitSuccess())).catchError((error) => emit(AppInitFailure(error)));
	}
}
