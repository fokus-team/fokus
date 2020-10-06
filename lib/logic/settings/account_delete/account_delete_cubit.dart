import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/logic/auth/formz_state.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'account_delete_state.dart';

class AccountDeleteCubit extends Cubit<AccountDeleteState> {
	final ActiveUserFunction _activeUser;

	final AuthenticationProvider _authenticationProvider = GetIt.I<AuthenticationProvider>();
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

  AccountDeleteCubit(this._activeUser) : super(AccountDeleteState());

	Future _deleteAccount() async {
		var user = _activeUser() as UICaregiver;
		var plans = await _dataRepository.getPlans(caregiverId: user.id, fields: ['tasks', '_id']);

		await _authenticationProvider.deleteAccount(state.password.value);
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

  Future accountDeleteFormSubmitted() async {
	  var state = this.state;
	  state = state.copyWith(password: Password.dirty(state.password.value, false));
	  state = state.copyWith(status: Formz.validate([state.password]));
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
	  try {
	  	await _deleteAccount();
		  emit(state.copyWith(status: FormzStatus.submissionSuccess));
	  } on PasswordConfirmFailure catch (e) {
		  emit(state.copyWith(status: FormzStatus.submissionFailure, error: e.reason));
	  } on Exception {
		  emit(state.copyWith(status: FormzStatus.submissionFailure));
	  }
  }

  void passwordChanged(String value) => emit(state.copyWith(password: Password.pure(value, false), status: FormzStatus.pure));
}
