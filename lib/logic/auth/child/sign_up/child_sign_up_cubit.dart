import 'package:formz/formz.dart';

import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/logic/auth/child/child_auth_cubit_base.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/auth/user_code.dart';
import 'package:fokus/utils/id_code_transformer.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/auth/formz_state.dart';

part 'child_sign_up_state.dart';

class ChildSignUpCubit extends ChildAuthCubitBase<ChildSignUpState> {
  ChildSignUpCubit(AuthenticationBloc authenticationBloc) : super(authenticationBloc, ChildSignUpState());

  Future<void> signUpFormSubmitted() async {
	  if (!state.status.isValidated) return;
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));

	  var caregiverId = getIdFromCode(state.caregiverCode.value);
	  var child = Child.create(name: state.name.value, avatar: 0, connections: [caregiverId]);
	  child.id = await dataRepository.createUser(child);
	  await dataRepository.updateUser(caregiverId, newConnections: [child.id]);
	  appConfigRepository.saveChildProfile(child.id);
	  authenticationBloc.add(AuthenticationChildLoginRequested(child));
	  emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  void caregiverCodeChanged(String value) async {
	  var caregiverField = UserCode.dirty(value);
	  var fieldState = Formz.validate([caregiverField, state.name]);
	  Set<int> takenAvatars;
	  if (fieldState == FormzStatus.valid) {
	  	if (await verifyUserCode(value, UserRole.caregiver))
			  takenAvatars = (await dataRepository.getUsers(connected: getIdFromCode(value), role: UserRole.child, fields: ['avatar'])).map((child) => child.avatar).toSet();
	  	else {
			  caregiverField = UserCode.dirty(value, false);
			  fieldState = Formz.validate([caregiverField, state.name]);
		  }
	  }
	  emit(state.copyWith(
		  caregiverCode: caregiverField,
		  status: fieldState,
		  takenAvatars: takenAvatars
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
