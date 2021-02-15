import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/logic/common/formz_state.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';

part 'account_delete_state.dart';

class AccountDeleteCubit extends Cubit<AccountDeleteState> {
	final ActiveUserFunction _activeUser;
	final UIUser _removedUser;

	final AuthenticationProvider _authenticationProvider = GetIt.I<AuthenticationProvider>();
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();

  AccountDeleteCubit(this._activeUser, Map<String, dynamic> args) :
		  _removedUser = args != null ? args['child'] : _activeUser(), super(AccountDeleteState());
	
	Future _deleteChild() async {
		var users = [_removedUser.id];
		var planInstances = await _dataRepository.getPlanInstances(childIDs: users, fields: ['_id']);
		await _authenticationProvider.confirmPassword(state.password.value);

		await Future.value([
			_dataRepository.removeUsers(users),
			_dataRepository.updateUser(_activeUser().id, removedConnections: users),
			_dataRepository.removePlanInstances(childIds: users),
			_dataRepository.removeTaskInstances(planInstancesIds: planInstances.map((plan) => plan.id).toList()),
		]);
		_appConfigRepository.removeSavedChildProfiles(users);
	}
	
	Future _deleteCaregiver() async {
		var users = [_removedUser.id];
		var plans = await _dataRepository.getPlans(caregiverId: _removedUser.id, fields: ['tasks', '_id']);
		await _authenticationProvider.deleteAccount(state.password.value);

		var hasConnections = _removedUser.connections != null && _removedUser.connections.isNotEmpty;
		if (hasConnections)
			users.addAll(_removedUser.connections);
		await Future.value([
			_dataRepository.removeUsers(users),
			_dataRepository.removePlans(caregiverId: _removedUser.id),
			if (hasConnections)
				_dataRepository.removePlanInstances(childIds: _removedUser.connections),
			_dataRepository.removeTasks(planIds: plans.map((e) => e.id).toList()),
			_dataRepository.removeTaskInstances(tasksIds: plans.fold<List<ObjectId>>([], (tasks, plan) => tasks..addAll(plan.tasks))),
			_dataRepository.removeRewards(createdBy: _removedUser.id),
		]);
		if (hasConnections)
			_appConfigRepository.removeSavedChildProfiles(_removedUser.connections);
	}

  Future accountDeleteFormSubmitted() async {
	  if (this.state.status != FormzStatus.pure)
		  return;
	  if ((_activeUser() as UICaregiver).authMethod == AuthMethod.email) {
		  var state = this.state;
		  state = state.copyWith(password: Password.dirty(state.password.value, false));
		  state = state.copyWith(status: Formz.validate([state.password]));
		  if (!state.status.isValidated) {
			  emit(state);
			  return;
		  }
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
	  try {
	  	await (_removedUser.id == _activeUser().id ? _deleteCaregiver() : _deleteChild());
		  emit(state.copyWith(status: FormzStatus.submissionSuccess));
	  } on PasswordConfirmFailure catch (e) {
		  emit(state.copyWith(status: FormzStatus.submissionFailure, error: e.reason));
	  } on Exception {
		  emit(state.copyWith(status: FormzStatus.submissionFailure));
	  }
  }

  void passwordChanged(String value) => emit(state.copyWith(password: Password.pure(value, false), status: FormzStatus.pure));
}
