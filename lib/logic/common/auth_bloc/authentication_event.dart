part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

class AuthenticationUserChanged extends AuthenticationEvent {
	final AuthenticatedUser user;

	const AuthenticationUserChanged(this.user);

	@override
	List<Object?> get props => [user];
}

class AuthenticationChildSignInRequested extends AuthenticationEvent {
	final Child child;

	const AuthenticationChildSignInRequested(this.child);

	@override
	List<Object?> get props => [child.id];
}

class AuthenticationSignOutRequested extends AuthenticationEvent {}

class AuthenticationActiveUserUpdated extends AuthenticationEvent {
	final User user;

	AuthenticationActiveUserUpdated(this.user);
	AuthenticationActiveUserUpdated.fromLocale(User user, String? locale) : user = (user is Caregiver) ?
			Caregiver.copyFrom(user, locale: locale) : Child.copyFrom(user as Child, locale: locale);

	@override
	List<Object?> get props => [user];
}
