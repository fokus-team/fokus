import 'package:fokus/logic/common/formz_state.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';


abstract class CaregiverAuthStateBase extends FormzState {
	final EmailSignInError signInError;

  CaregiverAuthStateBase(FormzStatus status, [this.signInError]) : super(status);

	CaregiverAuthStateBase copyWith({FormzStatus status, EmailSignInError signInError});

	@override
  List<Object> get props => [signInError];
}
