import 'package:flutter/widgets.dart' hide Action;
import 'package:fokus_auth/fokus_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../../common/cubit_base.dart';
import 'caregiver_auth_data_base.dart';

abstract class CaregiverAuthCubitBase<Data extends CaregiverAuthDataBase> extends CubitBase<Data> {
	@protected
	final AuthenticationProvider authenticationProvider = GetIt.I<AuthenticationProvider>();

  CaregiverAuthCubitBase(ModalRoute pageRoute, Data data) : super(pageRoute, initialData: data);

  Future<void> signInWithGoogle() => submit(
    initialData: data!.copyWith(authMethod: AuthMethod.google) as Data,
    body: () async {
      try {
        var result = await authenticationProvider.signInWithGoogle() == GoogleSignInOutcome.successful;
        return result ? Action.finish() : Action.cancel(data!.copyWith(authMethod: null) as Data);
      } on SignInFailure catch (e) {
        return Action.fail(data!.copyWith(signInError: e.reason) as Data);
      } on Exception {
        return Action.fail();
      }
    },
  );
}
