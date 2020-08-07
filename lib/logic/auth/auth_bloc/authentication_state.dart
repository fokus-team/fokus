part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated, unknown }

class AuthenticationState extends Equatable {
	final AuthenticationStatus status;
	final AuthUser user;

	const AuthenticationState._({
		this.status = AuthenticationStatus.unknown,
		this.user = AuthUser.empty,
	});

	const AuthenticationState.unknown() : this._();

	const AuthenticationState.authenticated(AuthUser user) : this._(status: AuthenticationStatus.authenticated, user: user);

	const AuthenticationState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated);

	@override
	List<Object> get props => [status, user];
}
