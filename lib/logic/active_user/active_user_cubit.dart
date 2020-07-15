import 'package:cubit/cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/ui/ui_user.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/database/data_repository.dart';
import 'package:fokus/services/settings/app_config_repository.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'active_user_state.dart';

class ActiveUserCubit extends Cubit<ActiveUserState> {
	final DataRepository _dbProvider = GetIt.I<DataRepository>();
	final AppConfigRepository _appConfig = GetIt.I<AppConfigRepository>();

  ActiveUserCubit() : super(NoActiveUser());

	void loginUser(User user) async {
		_appConfig.setLastUser(user.id);
		emit(ActiveUserPresent(UIUser(user.id, user.name, role: user.role)));
	}

  void logoutUser() {
	  _appConfig.removeLastUser();
	  emit(NoActiveUser());
  }

	// Temporary until we have a login page
	void loginUserByRole(UserRole role) async => loginUser(await _dbProvider.fetchUserByRole(role));
	void loginUserById(ObjectId id) async => loginUser(await _dbProvider.fetchUserById(id));
}
