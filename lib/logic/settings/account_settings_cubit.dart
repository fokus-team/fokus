import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/logic/auth/formz_state.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/model/ui/auth/confirmed_password.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus_auth/fokus_auth.dart';

part 'account_settings_state.dart';

class AccountSettingsCubit extends Cubit<AccountSettingsState> {
	final ActiveUserFunction _activeUser;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AuthenticationProvider _authenticationProvider = GetIt.I<AuthenticationProvider>();

  AccountSettingsCubit(this._activeUser) : super(AccountSettingsState());

  Future deleteAccount() async {
  	var user = _activeUser() as UICaregiver;
  	var plans = await _dataRepository.getPlans(caregiverId: user.id, fields: ['tasks', '_id']);
		return Future.value([
			_dataRepository.removeUsers(user.connections..add(user.id)),
			_dataRepository.removePlans(caregiverId: user.id),
			_dataRepository.removePlanInstances(childIds: user.connections),
			_dataRepository.removeTasks(planIds: plans.map((e) => e.id).toList()),
			_dataRepository.removeTaskInstances(tasksIds: plans.fold<List<ObjectId>>([], (tasks, plan) => tasks..addAll(plan.tasks))),
			_dataRepository.removeRewards(createdBy: user.id),
		]);
		// logout
	  // clear local data
	  // firebase
  }

  Future changePasswordFormSubmitted() async {
	  var state = _validateFields();
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
	  try {
		  await _authenticationProvider.changePassword(state.currentPassword.value, state.newPassword.value);
		  emit(state.copyWith(status: FormzStatus.submissionSuccess));
	  } on PasswordChangeFailure catch (e) {
		  emit(state.copyWith(status: FormzStatus.submissionFailure, error: e.reason));
	  } on Exception {
		  emit(state.copyWith(status: FormzStatus.submissionFailure));
	  }
  }

  bool isUserSignedInWithEmail() => _authenticationProvider.signedInWithEmail();

  AccountSettingsState _validateFields() {
	  var state = this.state;
	  state = state.copyWith(currentPassword: Password.dirty(state.currentPassword.value, false));
	  state = state.copyWith(newPassword: Password.dirty(state.newPassword.value));
	  state = state.copyWith(confirmedPassword: state.confirmedPassword.copyDirty(original: state.newPassword));
	  return state.copyWith(status: Formz.validate([state.currentPassword, state.newPassword, state.confirmedPassword, state.confirmedPassword]));
  }

  void currentPasswordChanged(String value) => emit(state.copyWith(currentPassword: Password.pure(value, false), status: FormzStatus.pure));
  void newPasswordChanged(String value) => emit(state.copyWith(newPassword: Password.pure(value), status: FormzStatus.pure));
  void confirmedPasswordChanged(String value) => emit(state.copyWith(confirmedPassword: state.confirmedPassword.copyPure(value: value), status: FormzStatus.pure));
}
