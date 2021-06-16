import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../services/app_config/app_config_repository.dart';
import '../../common/auth_bloc/authentication_bloc.dart';
import '../../common/user_code_verifier.dart';

class ChildAuthCubitBase<State> extends Cubit<State> with UserCodeVerifier<State> {
	@protected
	final AuthenticationBloc authenticationBloc;
	@protected
	final AppConfigRepository appConfigRepository = GetIt.I<AppConfigRepository>();

  ChildAuthCubitBase(this.authenticationBloc, State state) : super(state);
}
