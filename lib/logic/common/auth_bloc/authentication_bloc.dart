import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import '../../../model/db/user/caregiver.dart';
import '../../../model/db/user/child.dart';
import '../../../model/db/user/user.dart';
import '../../../model/db/user/user_role.dart';
import '../../../services/analytics_service.dart';
import '../../../services/app_config/app_config_repository.dart';
import '../../../services/data/data_repository.dart';
import '../../../services/exception/auth_exceptions.dart';
import '../../../services/observers/user/authenticated_user_notifier.dart';
import '../../../utils/ui/snackbar_utils.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
	final Logger _logger = Logger('AuthenticationBloc');

	final _authenticationProvider = GetIt.I<AuthenticationProvider>();
	final _appConfigRepository = GetIt.I<AppConfigRepository>();
	final _dataRepository = GetIt.I<DataRepository>();
	final _analyticsService = GetIt.I<AnalyticsService>();
	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();

	late StreamSubscription<AuthenticatedUser> _userSubscription;
	final AuthenticatedUserNotifier _userNotifier;

  AuthenticationBloc(this._userNotifier) : super(AuthenticationState.unknown()) {
	  _userSubscription = _authenticationProvider.user.listen((user) => add(AuthenticationUserChanged(user)));
  }

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
	  if (event is AuthenticationUserChanged)
		  yield await _processUserChangedEvent(event);
	  else if (event is AuthenticationChildSignInRequested) {
			_appConfigRepository.signInChild(event.child.id!);
			_analyticsService.logChildSignIn();
			yield await _signInUser(event.child);
	  } else if (event is AuthenticationSignOutRequested) {
		  if (state.user!.role == UserRole.caregiver)
		    _authenticationProvider.signOut();
		  else {
			  _appConfigRepository.signOutChild();
			  add(AuthenticationUserChanged(AuthenticatedUser.empty));
		  }
	  } else if (event is AuthenticationActiveUserUpdated) {
	  	_userNotifier.activeUser = event.user;
	    yield AuthenticationState.authenticated(event.user);
	  }
  }

	Future<AuthenticationState> _processUserChangedEvent(AuthenticationUserChanged event) async {
  	User? user;
	  var noSignedInUser = event.user == AuthenticatedUser.empty;
	  var wasAppOpened = state.status == AuthenticationStatus.initial;
	  if (noSignedInUser && !wasAppOpened) {
		  _userNotifier.userSignOutEvent(state.user!);
		  return const AuthenticationState.unauthenticated();
	  }
  	if (noSignedInUser && wasAppOpened)
  		return _attemptChildSignIn();
	  user = await _dataRepository.getUser(authenticationId: event.user.id);
  	// Discard unverified email users
  	if (await _userUnverified(event.user))
  		return _handleUnverifiedUser(user);
		return _signInCaregiver(event, user);
  }

	Future<AuthenticationState> _signInCaregiver(AuthenticationUserChanged event, User? user) async {
		if (user == null) {
			// New caregiver account
			if (! (await _authenticationProvider.userExists(event.user.email!))) {
				await _authenticationProvider.signOut();
				return const AuthenticationState.unauthenticated();
			}
			_logger.fine('Creating new user for ${event.user}');
			user = Caregiver.fromAuthUser(event.user);
			await _dataRepository.createUser(user);
			_analyticsService.logSignUp(event.user.authMethod!);
		} else
			_analyticsService.logSignIn(event.user.authMethod!);
		return _signInUser(user, event.user.authMethod, event.user.photoURL);
	}
  
  Future<AuthenticationState> _attemptChildSignIn() async {
	  var signedInChild = _appConfigRepository.getSignedInChild();
	  if (signedInChild != null) {
	  	var user = await _dataRepository.getUser(id: signedInChild);
	  	if (user != null) {
			  _analyticsService.logChildSignIn();
			  return _signInUser(user);
		  }
	  }
	  return const AuthenticationState.unauthenticated();
  }

	Future<bool> _userUnverified(AuthenticatedUser user) async => user.authMethod == AuthMethod.email && !user.emailVerified! && await _authenticationProvider.verificationEnforced();

	Future<AuthenticationState> _handleUnverifiedUser(User? user) async {
		if (user != null)
			showFailSnackbar(_navigatorKey.currentState!.context, EmailSignInError.accountNotVerified.key);
		_authenticationProvider.signOut();
		return const AuthenticationState.unauthenticated();
	}

	Future<AuthenticationState> _signInUser(User user, [AuthMethod? authMethod, String? photoURL]) async {
		_userNotifier.userSignInEvent(user);
	  return AuthenticationState.authenticated(user, authMethod: authMethod, photoURL: photoURL);
  }

	@override
	Future<void> close() {
		_userSubscription.cancel();
		return super.close();
	}
}
