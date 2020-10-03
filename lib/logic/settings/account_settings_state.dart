part of 'account_settings_cubit.dart';

class AccountSettingsState extends FormzState {
	final Password currentPassword;
	final Password newPassword;
	final ConfirmedPassword confirmedPassword;
	final PasswordChangeError error;

	AccountSettingsState({
		this.currentPassword = const Password.pure(),
		this.newPassword = const Password.pure(),
		this.confirmedPassword = const ConfirmedPassword.pure(),
		FormzStatus status = FormzStatus.pure,
		this.error
	}) : super(status);

	AccountSettingsState copyWith({Password currentPassword, Password newPassword, ConfirmedPassword confirmedPassword, FormzStatus status}) {
		return AccountSettingsState(
			currentPassword: currentPassword ?? this.currentPassword,
			newPassword: newPassword ?? this.newPassword,
			confirmedPassword: confirmedPassword ?? this.confirmedPassword,
			status: status ?? this.status,
			error: error
		);
	}

  @override
  List<Object> get props => [currentPassword, newPassword, confirmedPassword, status, error];
}
