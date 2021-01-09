import 'package:fokus/services/analytics_service.dart';
import 'package:formz/formz.dart';

import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/logic/child/auth/child_auth_cubit_base.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/auth/user_code.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/formz_state.dart';
import 'package:get_it/get_it.dart';

part 'child_sign_up_state.dart';

class ChildSignUpCubit extends ChildAuthCubitBase<ChildSignUpState> {
	final AuthenticationBloc _authBloc;
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();

  ChildSignUpCubit(this._authBloc) : super(_authBloc, ChildSignUpState(
	  caregiverCode: UserCode.pure(_authBloc.state.user != null ? getCodeFromId(_authBloc.state.user.id) : ''),
  )) {
  	if (codeFixed())
  	  _getTakenAvatars(state.caregiverCode.value).then((avatars) => emit(state.copyWith(takenAvatars: avatars)));
  }

  Future<void> signUpFormSubmitted() async {
	  var state = await _validateFields();
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));

	  var caregiverId = getIdFromCode(state.caregiverCode.value);
	  var child = Child.create(name: state.name.value, avatar: state.avatar, connections: [caregiverId]);
	  child.id = await dataRepository.createUser(child);
	  await dataRepository.updateUser(caregiverId, newConnections: [child.id]);
	  appConfigRepository.saveChildProfile(child.id);
	  if (!codeFixed())
		  authenticationBloc.add(AuthenticationChildSignInRequested(child));
	  _analyticsService.logChildSignUp();
	  emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  void caregiverCodeChanged(String value) async {
	  var caregiverField = UserCode.dirty(value);
	  Set<int> takenAvatars = {};
	  if (caregiverField.valid && await verifyUserCode(value, UserRole.caregiver))
			  takenAvatars = await _getTakenAvatars(value);
	  caregiverField = UserCode.pure(value);
	  emit(state.copyWith(
		  caregiverCode: caregiverField,
		  status: FormzStatus.pure,
		  takenAvatars: takenAvatars,
			avatar: (takenAvatars.contains(state.avatar)) ? null : state.avatar,
			clearableAvatar: true
	  ));
  }

  Future<Set<int>> _getTakenAvatars(String caregiverCode) async {
    return (await dataRepository.getUsers(connected: getIdFromCode(caregiverCode), role: UserRole.child, fields: ['avatar']))?.map((child) => child.avatar)?.toSet() ?? {};
  }

  bool codeFixed() => _authBloc.state.user != null;

  Future<ChildSignUpState> _validateFields() async {
	  var state = this.state;
	  var caregiverField = UserCode.dirty(state.caregiverCode.value.trim());
	  if (!codeFixed() && caregiverField.valid && !(await verifyUserCode(state.caregiverCode.value.trim(), UserRole.caregiver)))
		  caregiverField = UserCode.dirty(state.caregiverCode.value.trim(), false);
	  state = state.copyWith(caregiverCode: caregiverField);
	  state = state.copyWith(name: Name.dirty(state.name.value.trim()));
	  state = state.copyWith(avatar: state.avatar);
		var status = Formz.validate([state.name, state.caregiverCode]);
		if(state.avatar == null)
			status = FormzStatus.invalid;
	  return state.copyWith(status: status);
  }

  void nameChanged(String value) => emit(state.copyWith(name: Name.pure(value), status: FormzStatus.pure));

  void avatarChanged(int value) => emit(state.copyWith(avatar: value));
}
