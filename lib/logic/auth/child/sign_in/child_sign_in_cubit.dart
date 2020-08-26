import 'package:formz/formz.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/auth/child/child_auth_cubit_base.dart';
import 'package:fokus/logic/auth/formz_state.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/utils/id_code_transformer.dart';
import 'package:fokus/model/ui/auth/user_code.dart';

part 'child_sign_in_state.dart';

class ChildSignInCubit extends ChildAuthCubitBase<ChildSignInState> {
  ChildSignInCubit(AuthenticationBloc authenticationBloc) : super(authenticationBloc, ChildSignInState());

  void signInNewChild() async {
	  var state = await _validateFields();
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  if (!state.status.isValidated) return;
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
