import 'dart:async';

import 'package:get_it/get_it.dart';

import 'bloc.dart';
import 'package:bloc/bloc.dart';

import 'package:fokus/data/repository/database/data_repository.dart';
import 'package:fokus/data/repository/remote_config_provider.dart';
import 'package:fokus/data/repository/settings/app_config_repository.dart';
import 'package:fokus/data/repository/settings/app_shared_preferences_provider.dart';

class AppInitBloc extends Bloc<AppInitEvent, AppInitState> {
  @override
	AppInitState get initialState => InitialAppInitState();

  @override
	Stream<AppInitState> mapEventToState(AppInitEvent event) async* {
		if (event is AppInitStarted) {
			yield AppInitInProgress();
			await _initializeServices();
			yield AppInitSuccess();
		}
		else if (event is AppInitFailed)
			yield AppInitFailure(event.error);
	}

	Future _initializeServices() async {
  	var provider = GetIt.instance;
  	provider.registerSingletonAsync<RemoteConfigProvider>(() async => RemoteConfigProvider().initialize());
	  provider.registerSingletonAsync<AppConfigRepository>(() async => AppConfigRepository(AppSharedPreferencesProvider()).initialize());
	  provider.registerSingletonAsync<DataRepository>(
				() async => DataRepository().initialize(provider<RemoteConfigProvider>().dbAccessString),
			  dependsOn: [RemoteConfigProvider]
	  );
		return provider.allReady();
	}

  @override
	void onError(Object error, StackTrace stackTrace) {
		add(AppInitFailed(error)); // TODO Differentiate between no internet connection and db access error
	  super.onError(error, stackTrace);
	}
}
