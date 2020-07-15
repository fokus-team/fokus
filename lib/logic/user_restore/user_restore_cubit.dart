import 'package:cubit/cubit.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/services/settings/app_config_repository.dart';

import 'user_restore_state.dart';

class UserRestoreCubit extends Cubit<UserRestoreState> {
	final ActiveUserCubit _activeUserCubit;
	final AppConfigRepository _appConfig = GetIt.I<AppConfigRepository>();

	UserRestoreCubit(this._activeUserCubit) : super(UserRestoreInitialState()) {
		_activeUserCubit.listen((state) => state is ActiveUserPresent ? emit(UserRestoreSuccess(state.user.role)) : {});
	}

	void restoreUser() async {
		var appConfig = _appConfig ?? GetIt.I<AppConfigRepository>();
		var lastUser = appConfig.getLastUser();
		lastUser == null ? emit(UserRestoreFailure()) : _activeUserCubit.loginUserById(lastUser);
	}
}
