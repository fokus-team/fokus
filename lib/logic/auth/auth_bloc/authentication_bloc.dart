import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/auth_user.dart';
import 'package:fokus/services/auth/authentication_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
	final AuthenticationRepository _authenticationRepository = GetIt.I<AuthenticationRepository>();
	StreamSubscription<AuthUser> _userSubscription;

  AuthenticationBloc() : super(AuthenticationState.unknown()) {
	  _userSubscription = _authenticationRepository.user.listen((user) => add(AuthenticationUserChanged(user)));
  }

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
	  if (event is AuthenticationUserChanged) {
		  yield event.user != AuthUser.empty ? AuthenticationState.authenticated(event.user) : const AuthenticationState.unauthenticated();
	  } else if (event is AuthenticationLogoutRequested) {
		  _authenticationRepository.logOut();
	  }
  }

	@override
	Future<void> close() {
		_userSubscription?.cancel();
		return super.close();
	}
}
