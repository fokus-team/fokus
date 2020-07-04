import 'dart:async';
import 'bloc.dart';
import 'package:bloc/bloc.dart';

import 'package:fokus/data/repository/database/data_repository.dart';
import 'package:fokus/data/repository/remote_config_provider.dart';

class AppInitBloc extends Bloc<AppInitEvent, AppInitState> {
	final RemoteConfigProvider remoteConfig = RemoteConfigProvider();
	final DataRepository dbProvider;

	AppInitBloc(this.dbProvider);

  @override
	AppInitState get initialState => InitialAppInitState();

  @override
	Stream<AppInitState> mapEventToState(AppInitEvent event) async* {
		if (event is AppInitStartedEvent) {
			yield AppInitInProgressState();
			await remoteConfig.initialize(); // TODO split into init and fetch
			await dbProvider.initialize(remoteConfig.dbAccessString);

			var user = await dbProvider.fetchUser();
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
