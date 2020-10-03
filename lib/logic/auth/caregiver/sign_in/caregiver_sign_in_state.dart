part of 'caregiver_sign_in_cubit.dart';

class CaregiverSignInState extends CaregiverAuthStateBase {
	final Email email;
	final Password password;

	CaregiverSignInState({
		this.email = const Email.pure(),
		this.password = const Password.pure('', false),
		EmailSignInError signInError,
		FormzStatus status = FormzStatus.pure,
	}) : super(status, signInError);

	@override
	List<Object> get props => super.props..addAll([email, password, status]);

	CaregiverSignInState copyWith({Email email, Password password, FormzStatus status, EmailSignInError signInError}) {
		return CaregiverSignInState(
			email: email ?? this.email,
			password: password ?? this.password,
			status: status ?? this.status,
			signInError: signInError
		);
	}
}
