import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/services/data/data_repository.dart';

import 'user_restore_state.dart';

class UserRestoreCubit extends Cubit<UserRestoreState> {
	final ActiveUserCubit _activeUserCubit;
	final DataRepository _dbRepository = GetIt.I<DataRepository>();
	final AppConfigRepository _appConfig = GetIt.I<AppConfigRepository>();

	UserRestoreCubit(this._activeUserCubit) : super(UserRestoreInitialState()) {
		_activeUserCubit.listen((state) => state is ActiveUserPresent ? emit(UserRestoreSuccess(state.user.role)) : {});
	}

	void restoreUser() async {
		var appConfig = _appConfig ?? GetIt.I<AppConfigRepository>();
		var lastUserId = appConfig.getLastUser();
		if (lastUserId == null) {
			emit(UserRestoreFailure());
			return;
		}
		var user = await _dbRepository.getUser(id: lastUserId);
		if (user == null) {
			emit(UserRestoreFailure());
			return;
		}
		_activeUserCubit.loginUser(user);
	}
}
