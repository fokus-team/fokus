part of 'caregiver_sign_up_cubit.dart';

class CaregiverSignUpData extends CaregiverAuthDataBase {
	final EmailSignUpError? signUpError;

	CaregiverSignUpData({
		this.signUpError,
		EmailSignInError? signInError,
		AuthMethod? authMethod,
	}) : super(signInError: signInError, authMethod: authMethod);

	@override
	List<Object?> get props => super.props..add(signUpError);

	@override
  CaregiverSignUpData copyWith({EmailSignInError? signInError, EmailSignUpError? signUpError, AuthMethod? authMethod}) {
		return CaregiverSignUpData(
			signUpError: signUpError,
			signInError: signInError,
			authMethod: authMethod ?? this.authMethod
		);
	}
}
