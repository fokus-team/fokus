import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/logic/auth/formz_state.dart';
import 'package:fokus/model/ui/auth/user_code.dart';

part 'child_sign_in_state.dart';

class ChildSignInCubit extends Cubit<ChildSignInState> {
	final AuthenticationBloc _authenticationBloc;
	final AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();

  ChildSignInCubit(this._authenticationBloc) : super(ChildSignInState());

  void signInWithCachedId(ObjectId childId) async {
		_authenticationBloc.add(AuthenticationChildLoginRequested(childId));
  }

  void signInNewChild() async {
	  if (!state.status.isValidated) return;
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
  	var childId = ObjectId.parse(state.childCode.value); // TODO mangle/process in some way
	  _appConfigRepository.saveChildProfile(childId);
	  signInWithCachedId(childId);
	  emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

	void childCodeChanged(String value) {
		final userCode = UserCode.dirty(value);
		emit(state.copyWith(
			childCode: userCode,
			status: Formz.validate([userCode]),
		));
	}
}
