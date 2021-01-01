import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';

import 'package:fokus/logic/caregiver/auth/caregiver_auth_cubit_base.dart';
import 'package:fokus/model/ui/auth/email.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/logic/caregiver/auth/caregiver_auth_state_base.dart';

part 'caregiver_sign_in_state.dart';


class CaregiverSignInCubit extends CaregiverAuthCubitBase<CaregiverSignInState> {
  CaregiverSignInCubit(String email) : super(CaregiverSignInState(email: Email.pure(email ?? '')));

	Future<void> logInWithCredentials() async {
		var state = _validateFields();
		if (!state.status.isValidated) {
			emit(state);
			return;
		}
		emit(state.copyWith(status: FormzStatus.submissionInProgress));
		try {
			await authenticationProvider.signInWithEmail(
				email: state.email.value,
				password: state.password.value,
			);
			emit(state.copyWith(status: FormzStatus.submissionSuccess));
		} on SignInFailure catch (e) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, signInError: e.reason));
		} on Exception {
			emit(state.copyWith(status: FormzStatus.submissionFailure));
		}
	}

  Future<bool> resetPassword() async {
	  if (!_checkEmailInputField())
	    return false;
		try {
			await authenticationProvider.beginPasswordReset(state.email.value);
		} on SignInFailure catch (e) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, signInError: e.reason));
		} on PasswordResetFailure catch (e) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, passwordResetError: e.reason));
		}
	  return true;
  }

  Future<bool> resendVerificationEmail() async {
    if (!_checkEmailInputField())
      return false;
    await authenticationProvider.sendEmailVerification(state.email.value);
    return true;
  }

	bool _checkEmailInputField() {
    var state = this.state.copyWith(email: Email.dirty(this.state.email.value.trim()));
    if (state.email.invalid) {
      emit(state);
      return false;
    }
  }

  CaregiverSignInState _validateFields() {
	  var state = this.state;
	  state = state.copyWith(email: Email.dirty(state.email.value.trim()));
	  state = state.copyWith(password: Password.dirty(state.password.value, false));
	  return state.copyWith(status: Formz.validate([state.email, state.password]));
  }

  void emailChanged(String value) => emit(state.copyWith(email: Email.pure(value), status: FormzStatus.pure));

  void passwordChanged(String value) => emit(state.copyWith(password: Password.pure(value, false), status: FormzStatus.pure));
}
