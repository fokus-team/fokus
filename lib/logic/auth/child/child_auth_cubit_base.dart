import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/utils/id_code_transformer.dart';
import 'package:fokus/model/db/user/user_role.dart';

class ChildAuthCubitBase<State> extends Cubit<State> {
	@protected
	final AuthenticationBloc authenticationBloc;
	@protected
	final AppConfigRepository appConfigRepository = GetIt.I<AppConfigRepository>();
	@protected
	final DataRepository dataRepository = GetIt.I<DataRepository>();

  ChildAuthCubitBase(this.authenticationBloc, State state) : super(state);

	@protected
	Future<bool> verifyUserCode(String code, UserRole role) async {
		try {
			var userExists = await dataRepository.userExists(id: getIdFromCode(code), role: role);
			if (!userExists)
				return false;
		} catch (e) {
			return false;
		}
		return true;
	}
}
