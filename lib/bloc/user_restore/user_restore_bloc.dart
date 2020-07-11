import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';

import 'bloc.dart';
import 'package:fokus/data/repository/database/data_repository.dart';
import 'package:fokus/data/repository/settings/app_config_repository.dart';

class UserRestoreBloc extends Bloc<UserRestoreEvent, UserRestoreState> {
	final DataRepository dbProvider;
	final AppConfigRepository appConfig;

	UserRestoreBloc({this.dbProvider, this.appConfig});

  @override
  UserRestoreState get initialState => UserRestoreInitialState();

  @override
  Stream<UserRestoreState> mapEventToState(UserRestoreEvent event) async* {
	  var dbProvider = this.dbProvider ?? GetIt.I<DataRepository>();
	  var appConfig = this.appConfig ?? GetIt.I<AppConfigRepository>();

    if (event is UserRestoreStarted) {
	    var lastUser = appConfig.getLastUser();
	    if (lastUser == null)
	    	yield UserRestoreFailure();
	    else {
		    var user = await dbProvider.fetchUserById(lastUser);
		    yield UserRestoreSuccess(user);
	    }
    }
  }
}
