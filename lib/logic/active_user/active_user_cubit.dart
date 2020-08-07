import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/services/outdated_data_service.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';

part 'active_user_state.dart';

class ActiveUserCubit extends Cubit<ActiveUserState> {
	final DataRepository _dbRepository = GetIt.I<DataRepository>();
	final OutdatedDataService _outdatedDataService = GetIt.I<OutdatedDataService>();
	final AppConfigRepository _appConfig = GetIt.I<AppConfigRepository>();

  ActiveUserCubit() : super(NoActiveUser());

	void loginUser(User user) async {
		if (user == null) // TODO show in UI once we have a login page
			return;
		_appConfig.setLastUser(user.id);
		_outdatedDataService.onUserLogin(user.id, user.role);
		emit(ActiveUserPresent(UIUser.typedFromDBModel(user)));
	}

  void logoutUser() {
	  _appConfig.removeLastUser();
	  _outdatedDataService.onUserLogout();
	  emit(NoActiveUser());
  }

	// Temporary until we have a login page
	void loginUserByRole(UserRole role) async => loginUser(await _dbRepository.getUserByRole(role));
}
