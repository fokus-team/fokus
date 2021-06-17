import 'package:bloc/bloc.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';

import '../../../../model/db/user/caregiver.dart';
import '../../../../model/db/user/user.dart';
import '../../../../model/ui/auth/name.dart';
import '../../../../services/data/data_repository.dart';
import '../../../../utils/definitions.dart';
import '../../auth_bloc/authentication_bloc.dart';
import '../../formz_state.dart';

part 'name_change_state.dart';

class NameChangeCubit extends Cubit<NameChangeState> {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authBloc;
	final User _changedUser;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AuthenticationProvider _authenticationProvider = GetIt.I<AuthenticationProvider>();

  NameChangeCubit(this._activeUser, this._authBloc, User? _changedUser) :
		  _changedUser = _changedUser ?? _activeUser(),
      super(NameChangeState(name: Name.pure((_changedUser ?? _activeUser()).name!)));

  Future nameChangeFormSubmitted() async {
	  if (this.state.status != FormzStatus.pure)
		  return;
	  var state = this.state;
	  state = state.copyWith(name: Name.dirty(state.name.value));
	  state = state.copyWith(status: Formz.validate([state.name]));
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
	  var changingCaregiver = _changedUser.id == _activeUser().id;
		await Future.wait([
			_dataRepository.updateUser(_changedUser.id!, name: state.name.value),
			if (changingCaregiver)
				_authenticationProvider.changeName(state.name.value),
		]);
		if (changingCaregiver)
	    _authBloc.add(AuthenticationActiveUserUpdated(Caregiver.copyFrom(_activeUser() as Caregiver, name: state.name.value)));
	  emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  void nameChanged(String value) => emit(state.copyWith(name: Name.pure(value), status: FormzStatus.pure));
}
