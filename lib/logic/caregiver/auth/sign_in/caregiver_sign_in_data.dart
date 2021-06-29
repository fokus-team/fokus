part of 'caregiver_sign_in_cubit.dart';

class CaregiverSignInData extends CaregiverAuthDataBase {
	final EmailCodeError? passwordResetError;

	CaregiverSignInData({
		this.passwordResetError,
		EmailSignInError? signInError,
		FormzStatus status = FormzStatus.pure,
		AuthMethod? authMethod
	}) : super(signInError: signInError, authMethod: authMethod);

	@override
	List<Object?> get props => super.props..add(passwordResetError);

	@override
  CaregiverSignInData copyWith({EmailSignInError? signInError, EmailCodeError? passwordResetError, AuthMethod? authMethod}) {
		return CaregiverSignInData(
			signInError: signInError,
			passwordResetError: passwordResetError,
			authMethod: authMethod ?? this.authMethod
		);
	}
}
