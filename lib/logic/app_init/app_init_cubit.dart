import 'package:cubit/cubit.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/services/database/data_repository.dart';
import 'package:fokus/services/remote_config_provider.dart';
import 'package:fokus/services/settings/app_config_repository.dart';
import 'package:fokus/services/settings/app_shared_preferences_provider.dart';

import 'app_init_state.dart';

class AppInitCubit extends Cubit<AppInitState> {
	var _provider = GetIt.instance;

	AppInitCubit() : super(AppInitInProgress()) {
		_provider.registerSingleton<RemoteConfigProvider>(RemoteConfigProvider());
		_provider.registerSingleton<AppConfigRepository>(AppConfigRepository(AppSharedPreferencesProvider())..initialize());
		_provider.registerSingleton<DataRepository>(DataRepository());
		_provider.registerSingleton<PlanRepeatabilityService>(PlanRepeatabilityService());
		initializeApp();
	}

	void initializeApp() async {
		// TODO Differentiate between no internet connection and db access error

		await _provider<RemoteConfigProvider>().initialize().then(
			(_) => _provider<DataRepository>().initialize(_provider<RemoteConfigProvider>().dbAccessString)
		).then((_) => emit(AppInitSuccess())).catchError((error) => emit(AppInitFailure(error)));
	}
}
