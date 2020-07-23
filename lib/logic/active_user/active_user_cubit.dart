import 'package:cubit/cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';

part 'active_user_state.dart';

class ActiveUserCubit extends Cubit<ActiveUserState> {
	final DataRepository _dbRepository = GetIt.I<DataRepository>();
	final AppConfigRepository _appConfig = GetIt.I<AppConfigRepository>();

  ActiveUserCubit() : super(NoActiveUser());

	void loginUser(User user) async {
		_appConfig.setLastUser(user.id);
		emit(ActiveUserPresent(UIUser.typedFromDBModel(user)));
	}

  void logoutUser() {
	  _appConfig.removeLastUser();
	  emit(NoActiveUser());
  }

	// Temporary until we have a login page
	void loginUserByRole(UserRole role) async => loginUser(await _dbRepository.getUserByRole(role));
	void loginUserById(ObjectId id) async => loginUser(await _dbRepository.getUserById(id));
}
