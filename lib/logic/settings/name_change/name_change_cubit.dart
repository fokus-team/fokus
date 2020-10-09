import 'package:bloc/bloc.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:formz/formz.dart';

import 'package:fokus/logic/auth/formz_state.dart';
import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';

part 'name_change_state.dart';

class NameChangeCubit extends Cubit<NameChangeState> {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authBloc;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AuthenticationProvider _authenticationProvider = GetIt.I<AuthenticationProvider>();

  NameChangeCubit(this._activeUser, this._authBloc) : super(NameChangeState());

  Future nameChangeFormSubmitted() async {
	  var state = this.state;
	  state = state.copyWith(name: Name.dirty(state.name.value));
	  state = state.copyWith(status: Formz.validate([state.name]));
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
		await Future.value([
			_dataRepository.updateUser(_activeUser().id, name: state.name.value),
			_authenticationProvider.changeName(state.name.value),
		]);
	  _authBloc.add(AuthenticationActiveUserUpdated(UICaregiver.from(_activeUser(), name: state.name.value)));
	  emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  void nameChanged(String value) => emit(state.copyWith(name: Name.pure(value), status: FormzStatus.pure));
}
