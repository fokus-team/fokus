import 'package:fokus/logic/auth/formz_state.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';
import 'package:formz/formz.dart';


abstract class CaregiverAuthStateBase extends FormzState {
	final EmailSignInError signInError;

  CaregiverAuthStateBase(FormzStatus status, [this.signInError]) : super(status);

	CaregiverAuthStateBase copyWith({FormzStatus status, EmailSignInError signInError});
}
