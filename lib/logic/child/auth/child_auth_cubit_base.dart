import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:fokus/logic/common/user_code_verifier.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:fokus/model/db/user/user_role.dart';

class ChildAuthCubitBase<State> extends Cubit<State> with UserCodeVerifier<State> {
	@protected
	final AuthenticationBloc authenticationBloc;
	@protected
	final AppConfigRepository appConfigRepository = GetIt.I<AppConfigRepository>();

  ChildAuthCubitBase(this.authenticationBloc, State state) : super(state);
}
