import 'package:formz/formz.dart';

import 'package:fokus/model/ui/auth/confirmed_password.dart';
import 'package:fokus/model/ui/auth/email.dart';
import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/logic/auth/caregiver/caregiver_auth_cubit_base.dart';
import 'package:fokus/logic/auth/caregiver/caregiver_auth_state_base.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';

part 'caregiver_sign_up_state.dart';

class CaregiverSignUpCubit extends CaregiverAuthCubitBase<CaregiverSignUpState> {
  CaregiverSignUpCubit() : super(CaregiverSignUpState());

  Future<void> signUpFormSubmitted() async {
	  if (!state.status.isValidated) return;
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
	  try {
		  await authenticationRepository.signUpWithEmail(
			  email: state.email.value,
			  password: state.password.value,
			  name: state.name.value
		  );
		  emit(state.copyWith(status: FormzStatus.submissionSuccess));
	  } on EmailSignUpFailure catch (e) {
		  emit(state.copyWith(status: FormzStatus.submissionFailure, error: e.reason));
	  }
  }

	void nameChanged(String value) {
		final name = Name.dirty(value);
		emit(state.copyWith(
			name: name,
			status: Formz.validate([name, state.email, state.password, state.confirmedPassword]),
		));
	}

	void emailChanged(String value) {
		final email = Email.dirty(value);
		emit(state.copyWith(
			email: email,
			status: Formz.validate([state.name, email, state.password, state.confirmedPassword]),
		));
	}

	void passwordChanged(String value) {
		final password = Password.dirty(value);
		final confirmedPassword = state.confirmedPassword.copyWith(original: password);
		emit(state.copyWith(
			password: password,
			confirmedPassword: confirmedPassword,
			status: Formz.validate([state.name, state.email, password, confirmedPassword]),
		));
	}

  void confirmedPasswordChanged(String value) {
	  final confirmedPassword = state.confirmedPassword.copyWith(value: value);
	  emit(state.copyWith(
		  confirmedPassword: confirmedPassword,
		  status: Formz.validate([state.name, state.email, state.password, confirmedPassword]),
	  ));
  }
}
