part of 'account_delete_cubit.dart';

class AccountDeleteState extends FormzState {
	final Password password;
	final PasswordConfirmError error;

  const AccountDeleteState({
	  this.password = const Password.pure(),
	  FormzStatus status = FormzStatus.pure,
	  this.error
  }) : super(status);

	AccountDeleteState copyWith({Password password, PasswordConfirmError error, FormzStatus status}) {
		return AccountDeleteState(
				password: password ?? this.password,
				status: status ?? this.status,
				error: error ?? this.error
		);
	}

	@override
	List<Object> get props => [password, status, error];
}
