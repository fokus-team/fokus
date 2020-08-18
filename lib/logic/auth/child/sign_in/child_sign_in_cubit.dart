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
	  if (!state.status.isValidated) return;
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
  	var childId = getIdFromCode(state.childCode.value);
	  appConfigRepository.saveChildProfile(childId);
	  signInWithCachedId(childId);
	  emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

	void childCodeChanged(String value) async {
		var userCode = UserCode.dirty(value);
		var fieldState = Formz.validate([userCode]);
		if (fieldState == FormzStatus.valid && ! (await verifyUserCode(value, UserRole.child))) {
			userCode = UserCode.dirty(value, false);
			fieldState = Formz.validate([userCode]);
		}
		emit(state.copyWith(
			childCode: userCode,
			status: Formz.validate([userCode]),
		));
	}
}
