part of 'password_change_cubit.dart';

class PasswordChangeState extends FormzState {
	final Password currentPassword;
	final Password newPassword;
	final ConfirmedPassword confirmedPassword;
	final PasswordConfirmError error;
	final PasswordChangeType formType;
	final String passwordResetCode;

	PasswordChangeState({
		this.currentPassword = const Password.pure(),
		this.newPassword = const Password.pure(),
		this.confirmedPassword = const ConfirmedPassword.pure(),
		FormzStatus status = FormzStatus.pure,
		this.passwordResetCode,
		this.error,
		this.formType
	}) : super(status);

	PasswordChangeState copyWith({Password currentPassword, Password newPassword, ConfirmedPassword confirmedPassword, PasswordConfirmError error, String passwordResetCode, FormzStatus status}) {
		return PasswordChangeState(
			currentPassword: currentPassword ?? this.currentPassword,
			newPassword: newPassword ?? this.newPassword,
			confirmedPassword: confirmedPassword ?? this.confirmedPassword,
			status: status ?? this.status,
			error: error ?? this.error,
			passwordResetCode: passwordResetCode ?? this.passwordResetCode,
			formType: formType
		);
	}

  @override
  List<Object> get props => [currentPassword, newPassword, confirmedPassword, status, error];
}
