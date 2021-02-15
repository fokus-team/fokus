import 'package:formz/formz.dart';

import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/child/auth/child_auth_cubit_base.dart';
import 'package:fokus/logic/common/formz_state.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:fokus/model/ui/auth/user_code.dart';

part 'child_sign_in_state.dart';

class ChildSignInCubit extends ChildAuthCubitBase<ChildSignInState> {
  ChildSignInCubit(AuthenticationBloc authenticationBloc) : super(authenticationBloc, ChildSignInState());

  void signInNewChild() async {
	  if (this.state.status != FormzStatus.pure)
		  return;
	  var state = await _validateFields();
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
  	var childId = getIdFromCode(state.childCode.value);
	  appConfigRepository.saveChildProfile(childId);
	  authenticationBloc.add(AuthenticationChildSignInRequested(await dataRepository.getUser(id: childId)));
	  emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  Future<ChildSignInState> _validateFields() async {
	  var state = this.state;
	  var caregiverField = UserCode.dirty(state.childCode.value.trim());
	  if (caregiverField.valid && !(await verifyUserCode(state.childCode.value.trim(), UserRole.child)))
		  caregiverField = UserCode.dirty(state.childCode.value.trim(), false);
	  state = state.copyWith(childCode: caregiverField);
	  return state.copyWith(status: Formz.validate([state.childCode]));
  }

	void childCodeChanged(String value) => emit(state.copyWith(childCode: UserCode.pure(value), status: FormzStatus.pure));
}
