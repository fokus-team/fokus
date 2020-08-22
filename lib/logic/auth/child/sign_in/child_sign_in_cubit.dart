import 'package:formz/formz.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/auth/child/child_auth_cubit_base.dart';
import 'package:fokus/logic/auth/formz_state.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/utils/id_code_transformer.dart';
import 'package:fokus/model/ui/auth/user_code.dart';
import 'package:fokus/model/ui/user/ui_child.dart';

part 'child_sign_in_state.dart';

class ChildSignInCubit extends ChildAuthCubitBase<ChildSignInState> {
  ChildSignInCubit(AuthenticationBloc authenticationBloc) : super(authenticationBloc, ChildSignInState());

  void loadSavedProfiles() async {
	  var savedIds = appConfigRepository.getSavedChildProfiles() ?? [];
	  var children = await dataRepository.getUsers(ids: savedIds, fields: ['_id', 'name', 'avatar']);
	  emit(ChildSignInState(savedChildren: children.map((child) => UIChild.fromDBModel(child)).toList()));
  }

  void signInWithCachedId(ObjectId childId) async {
		authenticationBloc.add(AuthenticationChildSignInRequested(await dataRepository.getUser(id: childId)));
  }

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
	  signInWithCachedId(childId);
	  emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  Future<ChildSignInState> _validateFields() async {
	  var state = this.state;
	  var caregiverField = UserCode.dirty(state.childCode.value);
	  if (caregiverField.valid && !(await verifyUserCode(state.childCode.value, UserRole.child)))
		  caregiverField = UserCode.dirty(state.childCode.value, false);
	  state = state.copyWith(childCode: caregiverField);
	  return state.copyWith(status: Formz.validate([state.childCode]));
  }

	void childCodeChanged(String value) => emit(state.copyWith(childCode: UserCode.pure(value), status: FormzStatus.pure));
}
