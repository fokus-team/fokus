part of 'caregiver_sign_up_cubit.dart';

class CaregiverSignUpState extends CaregiverAuthStateBase {
	final Name name;
	final Email email;
	final Password password;
	final ConfirmedPassword confirmedPassword;
	final Agreement agreement;
	final EmailSignUpError? signUpError;

	CaregiverSignUpState({
		this.name = const Name.pure(),
		this.email = const Email.pure(),
		this.password = const Password.pure(),
		this.confirmedPassword = const ConfirmedPassword.pure(),
		this.agreement = const Agreement.pure(),
		this.signUpError,
		EmailSignInError? signInError,
		FormzStatus status = FormzStatus.pure,
		AuthMethod? authMethod
	}) : super(status, signInError, authMethod);

	@override
	List<Object?> get props => super.props..addAll([name, email, password, confirmedPassword, agreement, signUpError]);

	@override
  CaregiverSignUpState copyWith({Name? name, Email? email, Password? password, ConfirmedPassword? confirmedPassword, Agreement? agreement,
			EmailSignInError? signInError, EmailSignUpError? signUpError, FormzStatus? status, AuthMethod? authMethod}) {
		return CaregiverSignUpState(
			name: name ?? this.name,
			email: email ?? this.email,
			password: password ?? this.password,
			confirmedPassword: confirmedPassword ?? this.confirmedPassword,
			agreement: agreement ?? this.agreement,
			status: status ?? this.status,
			signUpError: signUpError,
			signInError: signInError,
			authMethod: authMethod ?? this.authMethod
		);
	}
}
