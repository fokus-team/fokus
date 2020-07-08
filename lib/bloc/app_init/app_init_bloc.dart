import 'dart:async';
import 'package:fokus/data/repository/settings/app_config_repository.dart';

import 'bloc.dart';
import 'package:bloc/bloc.dart';

import 'package:fokus/data/repository/database/data_repository.dart';
import 'package:fokus/data/repository/remote_config_provider.dart';

class AppInitBloc extends Bloc<AppInitEvent, AppInitState> {
	final RemoteConfigProvider _remoteConfig = RemoteConfigProvider();
	final DataRepository _dbProvider;
	final AppConfigRepository _appConfig;

	AppInitBloc(this._dbProvider, this._appConfig);

  @override
	AppInitState get initialState => InitialAppInitState();

  @override
	Stream<AppInitState> mapEventToState(AppInitEvent event) async* {
		if (event is AppInitStartedEvent) {
			yield AppInitInProgressState();
			await Future.wait([
				_remoteConfig.initialize(), // TODO split into init and fetch
				_appConfig.initialize()
			]);
			await _dbProvider.initialize(_remoteConfig.dbAccessString);

			var user = await _dbProvider.fetchUser();
			_appConfig.setLastUser(user.id);
			yield AppInitSuccessState(user);
		}
		else if (event is AppInitFailedEvent)
			yield AppInitFailureState(event.error);
	}

  @override
	void onError(Object error, StackTrace stackTrace) {
		add(AppInitFailedEvent(error)); // TODO Differentiate between no internet connection and db access error
	}
}
