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
		if (this.state.status != FormzStatus.pure)
			return;
		emit(state.copyWith(status: FormzStatus.submissionInProgress, authMethod: AuthMethod.google) as State);
		try {
			var result = await authenticationProvider.signInWithGoogle() == GoogleSignInOutcome.successful;
			emit((result ? state.copyWith(status: FormzStatus.submissionSuccess) : state.copyWith(status: FormzStatus.pure, authMethod: null)) as State);
		} on SignInFailure catch (e) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, signInError: e.reason) as State);
		} on Exception {
			emit(state.copyWith(status: FormzStatus.submissionFailure) as State);
		}
	}
}
