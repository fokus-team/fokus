import 'package:bloc/bloc.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

import 'caregiver_auth_state_base.dart';

class CaregiverAuthCubitBase<State extends CaregiverAuthStateBase> extends Cubit<State> {
	@protected
	final AuthenticationProvider authenticationProvider = GetIt.I<AuthenticationProvider>();

  CaregiverAuthCubitBase(State state) : super(state);

	Future<void> logInWithGoogle() async {
		emit(state.copyWith(status: FormzStatus.submissionInProgress));
		try {
			await authenticationProvider.signInWithGoogle();
			emit(state.copyWith(status: FormzStatus.submissionSuccess));
		} on SignInFailure catch (e) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, signInError: e.reason));
		} on Exception {
			emit(state.copyWith(status: FormzStatus.submissionFailure));
		}
	}
}
