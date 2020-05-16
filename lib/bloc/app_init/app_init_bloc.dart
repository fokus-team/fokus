import 'dart:async';
import 'bloc.dart';
import 'package:bloc/bloc.dart';

import 'package:fokus/data/repository/database/data_repository.dart';
import 'package:fokus/data/repository/remote_config_provider.dart';

class AppInitBloc extends Bloc<AppInitEvent, AppInitState> {
	RemoteConfigProvider remoteConfig = RemoteConfigProvider();
	DataRepository dbProvider;

	@override
	AppInitState get initialState => AppInitState.APP_UNINITIALIZED;

  @override
	Stream<AppInitState> mapEventToState(AppInitEvent event) async* {
		if (event == AppInitEvent.INITIALIZATION_STARTED) {
			yield AppInitState.APP_INIT_STARTED;
			await remoteConfig.initialize(); // TODO split into init and fetch
			dbProvider = DataRepository(remoteConfig.dbAccessConfig);
			await dbProvider.testConnection();
			yield AppInitState.APP_INITIALIZED;
		}
		else if (event == AppInitEvent.INITIALIZATION_FAILED)
			yield AppInitState.APP_DISCONNECTED;
	}

  @override
	void onError(Object error, StackTrace stackTrace) {
  	super.onError(error, stackTrace);
		add(AppInitEvent.INITIALIZATION_FAILED); // TODO Differentiate between no internet connection and db access error
	}
}
