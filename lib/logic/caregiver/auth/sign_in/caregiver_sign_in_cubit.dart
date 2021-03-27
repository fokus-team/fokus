// @dart = 2.10
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
		if (this.state.status != FormzStatus.pure || !_validateFields())
			return;
		emit(state.copyWith(status: FormzStatus.submissionInProgress, authMethod: AuthMethod.email));
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
	  var state = this.state.copyWith(email: Email.dirty(this.state.email.value.trim()));
	  if (state.email.invalid) {
		  emit(state);
		  return false;
	  }
		try {
			await authenticationProvider.beginPasswordReset(state.email.value);
		} on SignInFailure catch (e) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, signInError: e.reason));
			return false;
		} on EmailCodeFailure catch (e) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, passwordResetError: e.reason));
			return false;
		}
	  return true;
  }

  Future<VerificationAttemptOutcome> resendVerificationEmail() async {
    if (!_validateFields())
      return null;
    try {
	    return await authenticationProvider.sendEmailVerification(email: state.email.value, password: state.password.value);
    } on SignInFailure catch (e) {
	    emit(state.copyWith(status: FormzStatus.submissionFailure, signInError: e.reason));
	    return null;
    }
  }

  bool _validateFields() {
	  var state = this.state;
	  state = state.copyWith(email: Email.dirty(state.email.value.trim()));
	  state = state.copyWith(password: Password.dirty(state.password.value, false));
	  state = state.copyWith(status: Formz.validate([state.email, state.password]));
	  if (!state.status.isValidated) {
		  emit(state);
		  return false;
	  }
	  return true;
  }

  void emailChanged(String value) => emit(state.copyWith(email: Email.pure(value), status: FormzStatus.pure));

  void passwordChanged(String value) => emit(state.copyWith(password: Password.pure(value, false), status: FormzStatus.pure));
}
