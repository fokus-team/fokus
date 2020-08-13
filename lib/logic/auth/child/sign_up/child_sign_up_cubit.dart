import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';

import 'package:fokus/logic/auth/formz_state.dart';
import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/model/ui/auth/user_code.dart';

part 'child_sign_up_state.dart';

class ChildSignUpCubit extends Cubit<ChildSignUpState> {
  ChildSignUpCubit() : super(ChildSignUpState());

  Future<void> signUpFormSubmitted() async {
	  if (!state.status.isValidated) return;
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
	  emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  void caregiverCodeChanged(String value) {
	  final caregiverCode = UserCode.dirty(value);
	  emit(state.copyWith(
		  caregiverCode: caregiverCode,
		  status: Formz.validate([caregiverCode, state.name]),
	  ));
  }

  void nameChanged(String value) {
	  final name = Name.dirty(value);
	  emit(state.copyWith(
		  name: name,
		  status: Formz.validate([name, state.caregiverCode]),
	  ));
  }
}
