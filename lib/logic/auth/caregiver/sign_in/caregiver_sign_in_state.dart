part of 'caregiver_sign_in_cubit.dart';

class CaregiverSignInState extends CaregiverAuthStateBase {
	final Email email;
	final Password password;

	CaregiverSignInState({
		this.email = const Email.pure(),
		this.password = const Password.pure(false),
		FormzStatus status = FormzStatus.pure,
	}) : super(status);

	@override
	List<Object> get props => [email, password, status];

	CaregiverSignInState copyWith({Email email, Password password, FormzStatus status}) {
		return CaregiverSignInState(
			email: email ?? this.email,
			password: password ?? this.password,
			status: status ?? this.status,
		);
	}
}
