import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/auth_user.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/outdated_data_service.dart';
import 'package:fokus/services/auth/authentication_repository.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
	final Logger _logger = Logger('AuthenticationBloc');

	AuthenticationRepository _authenticationRepository = GetIt.I<AuthenticationRepository>();
	AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();
	DataRepository _dataRepository = GetIt.I<DataRepository>();
	final OutdatedDataService _outdatedDataService = GetIt.I<OutdatedDataService>();

	StreamSubscription<AuthenticatedUser> _userSubscription;

  AuthenticationBloc() : super(AuthenticationState.unknown()) {
	  _userSubscription = _authenticationRepository.user.listen((user) => add(AuthenticationUserChanged(user)));
  }

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
	  if (event is AuthenticationUserChanged)
		  yield await _processUserChangedEvent(event);
	  else if (event is AuthenticationChildSignInRequested) {
			_appConfigRepository.signInChild(event.child.id);
			_outdatedDataService.onUserSignOut();
			yield _signInUser(event.child);
	  } else if (event is AuthenticationSignOutRequested) {
	  	_outdatedDataService.onUserSignOut();
		  _logger.fine('Signing out user ${state.user}');
		  if (state.user.role == UserRole.caregiver)
		    _authenticationRepository.logOut();
		  else {
			  _appConfigRepository.signOutChild();
			  add(AuthenticationUserChanged(AuthenticatedUser.empty));
		  }
	  }
  }

	Future<AuthenticationState> _processUserChangedEvent(AuthenticationUserChanged event) async {
  	User user;
	  var noSignedInCaregiver = event.user == AuthenticatedUser.empty;
	  var wasAppOpened = state.status == AuthenticationStatus.initial;
	  if (noSignedInCaregiver && !wasAppOpened)
		  return const AuthenticationState.unauthenticated();
  	if (noSignedInCaregiver && wasAppOpened) {
		  var signedInChild = _appConfigRepository.getSignedInChild();
		  if (signedInChild != null)
			  return _signInUser(await _dataRepository.getUser(id: signedInChild));
		  else
		    return const AuthenticationState.unauthenticated();
	  }
		user = await _dataRepository.getUser(authenticationId: event.user.id);
		if (user == null) {
			_logger.fine('Creating new user for ${event.user}');
			var user = Caregiver.fromAuthUser(event.user);
			user.id = await _dataRepository.createUser(user);
		}
		return _signInUser(user);
  }

	AuthenticationState _signInUser(User user) {
	  _outdatedDataService.onUserSignIn(user.id, user.role);
	  return AuthenticationState.authenticated(UIUser.typedFromDBModel(user));
  }

	@override
	Future<void> close() {
		_userSubscription?.cancel();
		return super.close();
	}
}
