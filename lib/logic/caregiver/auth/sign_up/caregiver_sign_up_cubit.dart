import 'package:flutter/widgets.dart' hide Action;
import 'package:fokus_auth/fokus_auth.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../caregiver_auth_cubit_base.dart';
import '../caregiver_auth_data_base.dart';

part 'caregiver_sign_up_data.dart';

class CaregiverSignUpCubit extends CaregiverAuthCubitBase<CaregiverSignUpData> {
  CaregiverSignUpCubit(ModalRoute pageRoute) : super(pageRoute, CaregiverSignUpData());

  Future<void> signUpWithEmail({required String email, required String password, required String name}) => submit(
    initialData: state.data!.copyWith(authMethod: AuthMethod.email),
    body: () async {
      try {
        await authenticationProvider.signUpWithEmail(email: email, password: password, name: name);
        return Action.finish();
      } on EmailSignUpFailure catch (e) {
        return Action.fail(state.data!.copyWith(signUpError: e.reason));
      } on Exception {
        return Action.fail();
      }
    },
  );

  Future<bool> verificationEnforced() => authenticationProvider.verificationEnforced();
}
