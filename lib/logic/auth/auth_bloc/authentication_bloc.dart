import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:logging/logging.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/observers/active_user_observer.dart';
import 'package:fokus/services/plan_keeper_service.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/locale_provider.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
	final Logger _logger = Logger('AuthenticationBloc');

	final AuthenticationProvider _authenticationProvider = GetIt.I<AuthenticationProvider>();
	final AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	StreamSubscription<AuthenticatedUser> _userSubscription;
	List<ActiveUserObserver> _userObservers = [];

  AuthenticationBloc() : super(AuthenticationState.unknown()) {
	  observeUserChanges(GetIt.I<PlanKeeperService>());
	  observeUserChanges(GetIt.I<NotificationService>());
	  observeUserChanges(GetIt.I<LocaleService>());
	  _userSubscription = _authenticationProvider.user.listen((user) => add(AuthenticationUserChanged(user)));
  }

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
	  if (event is AuthenticationUserChanged)
		  yield await _processUserChangedEvent(event);
	  else if (event is AuthenticationChildSignInRequested) {
			_appConfigRepository.signInChild(event.child.id);
			yield await _signInUser(event.child);
	  } else if (event is AuthenticationSignOutRequested) {
	  	_onUserSignOut(state.user.toDBModel());
		  if (state.user.role == UserRole.caregiver)
		    _authenticationProvider.signOut();
		  else {
			  _appConfigRepository.signOutChild();
			  add(AuthenticationUserChanged(AuthenticatedUser.empty));
		  }
	  } else if (event is AuthenticationActiveUserUpdated)
		  yield AuthenticationState.authenticated(event.user);
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
			if (! (await _authenticationProvider.userExists(event.user.email))) {
				await _authenticationProvider.signOut();
				return const AuthenticationState.unauthenticated();
			}
			_logger.fine('Creating new user for ${event.user}');
			user = Caregiver.fromAuthUser(event.user);
			await _dataRepository.createUser(user);
		}
		return _signInUser(user, event.user.authMethod);
  }

	Future<AuthenticationState> _signInUser(User user, [AuthMethod authMethod]) async {
	  _onUserSignIn(user);
	  return AuthenticationState.authenticated(UIUser.typedFromDBModel(user, authMethod));
  }

	@override
	Future<void> close() {
		_userSubscription?.cancel();
		return super.close();
	}

	void observeUserChanges(ActiveUserObserver observer) => _userObservers.add(observer);
  void _onUserSignIn(User user) => _userObservers.forEach((observer) => observer.onUserSignIn(user));
  void _onUserSignOut(User user) => _userObservers.forEach((observer) => observer.onUserSignOut(user));
}
