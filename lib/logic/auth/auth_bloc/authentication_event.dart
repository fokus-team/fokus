part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationUserChanged extends AuthenticationEvent {
	final AuthenticatedUser user;

	const AuthenticationUserChanged(this.user);

	@override
	List<Object> get props => [user];
}

class AuthenticationChildLoginRequested extends AuthenticationEvent {
	final ObjectId childId;

	const AuthenticationChildLoginRequested(this.childId);

	@override
	List<Object> get props => [childId];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}
