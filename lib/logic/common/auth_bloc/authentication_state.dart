part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated, initial }

class AuthenticationState extends Equatable {
	final AuthenticationStatus status;
	final User? user;
	final AuthMethod? authMethod;
	final String? photoURL;

	bool get signedIn => status == AuthenticationStatus.authenticated;

	const AuthenticationState._({
		this.status = AuthenticationStatus.initial,
		this.user,
		this.authMethod,
		this.photoURL,
	});

	const AuthenticationState.unknown() : this._();

	const AuthenticationState.authenticated(this.user, {this.authMethod, this.photoURL}) : status = AuthenticationStatus.authenticated;

	const AuthenticationState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated);

	@override
	List<Object?> get props => [status, user];
}
