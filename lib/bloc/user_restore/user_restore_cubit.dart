import 'package:cubit/cubit.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/bloc/active_user/active_user_cubit.dart';
import 'package:fokus/data/repository/settings/app_config_repository.dart';

import 'user_restore_state.dart';

class UserRestoreCubit extends Cubit<UserRestoreState> {
	final ActiveUserCubit _activeUserCubit;
	final AppConfigRepository appConfig;

	UserRestoreCubit(this._activeUserCubit, {this.appConfig}) : super(UserRestoreInitialState()) {
		_activeUserCubit.listen((state) => state is ActiveUserPresent ? emit(UserRestoreSuccess(state.role)) : {});
	}

	void restoreUser() async {
		var appConfig = this.appConfig ?? GetIt.I<AppConfigRepository>();
		var lastUser = appConfig.getLastUser();
		lastUser == null ? emit(UserRestoreFailure()) : _activeUserCubit.loginUserById(lastUser);
	}
}
