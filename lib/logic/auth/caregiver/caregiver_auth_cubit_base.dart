import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

import 'package:fokus/services/auth/authentication_repository.dart';

import 'caregiver_auth_state_base.dart';

class CaregiverAuthCubitBase<State extends CaregiverAuthStateBase> extends Cubit<State> {
	@protected
	final AuthenticationRepository authenticationRepository = GetIt.I<AuthenticationRepository>();

  CaregiverAuthCubitBase(State state) : super(state);

	Future<void> logInWithGoogle() async {
		emit(state.copyWith(status: FormzStatus.submissionInProgress));
		try {
			await authenticationRepository.logInWithGoogle();
			emit(state.copyWith(status: FormzStatus.submissionSuccess));
		} on Exception {
			emit(state.copyWith(status: FormzStatus.submissionFailure));
		} on NoSuchMethodError {
			emit(state.copyWith(status: FormzStatus.pure));
		}
	}
}
