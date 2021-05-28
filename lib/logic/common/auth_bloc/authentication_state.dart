part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated, initial }

class AuthenticationState extends Equatable {
	final AuthenticationStatus status;
	final UIUser? user;

	bool get signedIn => status == AuthenticationStatus.authenticated;

	const AuthenticationState._({
		this.status = AuthenticationStatus.initial,
		this.user,
	});

	const AuthenticationState.unknown() : this._();

	const AuthenticationState.authenticated(UIUser user) : this._(status: AuthenticationStatus.authenticated, user: user);

	const AuthenticationState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated);

	@override
	List<Object?> get props => [status, user];
}
