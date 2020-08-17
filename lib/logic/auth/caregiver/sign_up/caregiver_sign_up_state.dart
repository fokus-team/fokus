part of 'caregiver_sign_up_cubit.dart';

class CaregiverSignUpState extends CaregiverAuthStateBase {
	final Name name;
	final Email email;
	final Password password;
	final ConfirmedPassword confirmedPassword;
	final EmailSignUpError response;

	CaregiverSignUpState({
		this.name = const Name.pure(),
		this.email = const Email.pure(),
		this.password = const Password.pure(),
		this.confirmedPassword = const ConfirmedPassword.pure(),
		this.response,
		FormzStatus status = FormzStatus.pure,
	}) : super(status);

	@override
	List<Object> get props => [name, email, password, confirmedPassword, status];

	CaregiverSignUpState copyWith({Name name, Email email, Password password, ConfirmedPassword confirmedPassword, EmailSignUpError error, FormzStatus status}) {
		return CaregiverSignUpState(
			name: name ?? this.name,
			email: email ?? this.email,
			password: password ?? this.password,
			confirmedPassword: confirmedPassword ?? this.confirmedPassword,
			status: status ?? this.status,
			response: error
		);
	}
}
