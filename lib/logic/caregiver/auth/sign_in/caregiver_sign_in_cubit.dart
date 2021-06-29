import 'package:fokus_auth/fokus_auth.dart';
import 'package:flutter/widgets.dart' hide Action;
import 'package:formz/formz.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../caregiver_auth_cubit_base.dart';
import '../caregiver_auth_data_base.dart';

part 'caregiver_sign_in_data.dart';


class CaregiverSignInCubit extends CaregiverAuthCubitBase<CaregiverSignInData> {
  CaregiverSignInCubit(ModalRoute pageRoute) : super(pageRoute, CaregiverSignInData());

	Future<void> signInWithEmail({required String email, required String password}) => submit(
    initialData: state.data!.copyWith(authMethod: AuthMethod.email),
    body: () async {
      try {
        await authenticationProvider.signInWithEmail(email: email, password: password);
        return Action.finish();
      } on SignInFailure catch (e) {
        return Action.fail(state.data!.copyWith(signInError: e.reason));
      } on Exception {
        return Action.fail();
      }
    },
  );

  Future<bool> resetPassword(String email) async {
    late bool success;
    await submit(body: () async {
      try {
        await authenticationProvider.beginPasswordReset(email);
        success = true;
        return Action.finish();
      } on SignInFailure catch (e) {
        success = false;
        return Action.fail(state.data!.copyWith(signInError: e.reason));
      } on EmailCodeFailure catch (e) {
        success = false;
        return Action.fail(state.data!.copyWith(passwordResetError: e.reason));
      }
    });
    return success;
  }

  Future<VerificationAttemptOutcome?> resendVerificationEmail({required String email, required String password}) async {
    VerificationAttemptOutcome? outcome;
    await submit(body: () async {
      try {
        outcome = await authenticationProvider.sendEmailVerification(email: email, password: password);
        return Action.finish();
      } on SignInFailure catch (e) {
        return Action.fail(state.data!.copyWith(signInError: e.reason));
      }
    });
    return outcome;
  }
}
