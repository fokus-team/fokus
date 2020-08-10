import 'package:formz/formz.dart';

import '../formz_state.dart';

abstract class CaregiverAuthStateBase extends FormzState {
  CaregiverAuthStateBase(FormzStatus status) : super(status);

	CaregiverAuthStateBase copyWith({FormzStatus status});
}
