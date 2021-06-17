import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';

import '../../../../model/ui/auth/agreement.dart';
import '../../../../model/ui/auth/confirmed_password.dart';
import '../../../../model/ui/auth/email.dart';
import '../../../../model/ui/auth/name.dart';
import '../../../../model/ui/auth/password.dart';
import '../caregiver_auth_cubit_base.dart';
import '../caregiver_auth_state_base.dart';

part 'caregiver_sign_up_state.dart';

class CaregiverSignUpCubit extends CaregiverAuthCubitBase<CaregiverSignUpState> {
  CaregiverSignUpCubit() : super(CaregiverSignUpState());

  Future<void> signUpFormSubmitted() async {
	  if (this.state.status != FormzStatus.pure)
		  return;
	  var state = _validateFields();
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress, authMethod: AuthMethod.email));
	  try {
		  await authenticationProvider.signUpWithEmail(
			  email: state.email.value,
			  password: state.password.value,
			  name: state.name.value
		  );
		  emit(state.copyWith(status: FormzStatus.submissionSuccess));
	  } on EmailSignUpFailure catch (e) {
		  emit(state.copyWith(status: FormzStatus.submissionFailure, signUpError: e.reason));
	  } on Exception {
		  emit(state.copyWith(status: FormzStatus.submissionFailure));
	  }
  }

  CaregiverSignUpState _validateFields() {
	  var state = this.state;
	  state = state.copyWith(email: Email.dirty(state.email.value.trim()));
	  state = state.copyWith(name: Name.dirty(state.name.value.trim()));
	  state = state.copyWith(password: Password.dirty(state.password.value));
	  state = state.copyWith(agreement: Agreement.dirty(state.agreement.value));
	  state = state.copyWith(confirmedPassword: state.confirmedPassword.copyDirty(original: state.password));
	  return state.copyWith(status: Formz.validate([state.email, state.password, state.name, state.confirmedPassword, state.agreement]));
  }

	void nameChanged(String value) => emit(state.copyWith(name: Name.pure(value), status: FormzStatus.pure));

  void emailChanged(String value) => emit(state.copyWith(email: Email.pure(value), status: FormzStatus.pure));

  void passwordChanged(String value) => emit(state.copyWith(password: Password.pure(value), status: FormzStatus.pure));

  void confirmedPasswordChanged(String value) => emit(state.copyWith(confirmedPassword: state.confirmedPassword.copyPure(value: value), status: FormzStatus.pure));

	void agreementChanged(bool value) => emit(state.copyWith(agreement: Agreement.pure(value), status: FormzStatus.pure));

  Future<bool> verificationEnforced() => authenticationProvider.verificationEnforced();
}
