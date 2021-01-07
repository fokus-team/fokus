import 'package:fokus/logic/common/formz_state.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';


abstract class CaregiverAuthStateBase extends FormzState {
	final EmailSignInError signInError;
	final AuthMethod authMethod;

  CaregiverAuthStateBase(FormzStatus status, [this.signInError, this.authMethod]) : super(status);

	CaregiverAuthStateBase copyWith({FormzStatus status, EmailSignInError signInError, AuthMethod authMethod});

	@override
  List<Object> get props => [signInError, status];
}
