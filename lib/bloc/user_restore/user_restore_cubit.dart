import 'package:cubit/cubit.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/data/repository/database/data_repository.dart';
import 'package:fokus/data/repository/settings/app_config_repository.dart';

import 'user_restore_state.dart';

class UserRestoreCubit extends Cubit<UserRestoreState> {
	final DataRepository dbProvider;
	final AppConfigRepository appConfig;

	UserRestoreCubit({this.dbProvider, this.appConfig}) : super(UserRestoreInitialState());

	void initiateUserRestore() async {
		var dbProvider = this.dbProvider ?? GetIt.I<DataRepository>();
		var appConfig = this.appConfig ?? GetIt.I<AppConfigRepository>();

		var lastUser = appConfig.getLastUser();
		if (lastUser == null)
			emit(UserRestoreFailure());
		else {
		var user = await dbProvider.fetchUserById(lastUser);
			emit(UserRestoreSuccess(user));
		}
	}
}
