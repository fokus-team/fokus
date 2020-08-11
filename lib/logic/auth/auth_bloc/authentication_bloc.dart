import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/auth_user.dart';
import 'package:fokus/services/auth/authentication_repository.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/user_role.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
	final Logger _logger = Logger('AuthenticationBloc');

	AuthenticationRepository _authenticationRepository = GetIt.I<AuthenticationRepository>();
	DataRepository _dbRepository;
	StreamSubscription<AuthenticatedUser> _userSubscription;

  AuthenticationBloc() : super(AuthenticationState.unknown()) {
	  _userSubscription = _authenticationRepository.user.listen((user) => add(AuthenticationUserChanged(user)));
  }

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
	  _dbRepository ??= GetIt.I<DataRepository>();

	  if (event is AuthenticationUserChanged)
		  yield await _processUserChangedEvent(event);
	  else if (event is AuthenticationLogoutRequested) {
		  _logger.fine('Signing out user ${state.user}');
		  _authenticationRepository.logOut();
	  }
  }

	Future<AuthenticationState> _processUserChangedEvent(AuthenticationUserChanged event) async {
  	if (event.user == AuthenticatedUser.empty)
  		return const AuthenticationState.unauthenticated();
		var user = await _dbRepository.getUser(authenticationId: event.user.id, role: UserRole.caregiver);
		if (user == null) {
			_logger.fine('Creating new user for ${event.user}');
			_dbRepository.createUser(Caregiver.fromAuthUser(event.user));
			user = await _dbRepository.getUser(authenticationId: event.user.id, role: UserRole.caregiver);
		}
		return AuthenticationState.authenticated(UIUser.typedFromDBModel(user));
  }

	@override
	Future<void> close() {
		_userSubscription?.cancel();
		return super.close();
	}
}
