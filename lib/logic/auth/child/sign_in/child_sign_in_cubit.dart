import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
part 'child_sign_in_state.dart';

class ChildSignInCubit extends Cubit<ChildSignInState> {
	final AuthenticationBloc _authenticationBloc;
	final AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();

  ChildSignInCubit(this._authenticationBloc) : super(ChildSignInState());

  void signInWithCachedId(ObjectId childId) async {
		_authenticationBloc.add(AuthenticationChildLoginRequested(childId));
  }

  void signInNewChild(String childCode) async {
  	var childId = ObjectId.parse(childCode); // TODO mangle/process in some way
	  _appConfigRepository.saveChildProfile(childId);
	  signInWithCachedId(childId);
  }
}
