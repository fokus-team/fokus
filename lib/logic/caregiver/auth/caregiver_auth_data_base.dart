import 'package:equatable/equatable.dart';
import 'package:fokus_auth/fokus_auth.dart';


abstract class CaregiverAuthDataBase extends Equatable {
	final EmailSignInError? signInError;
	final AuthMethod? authMethod;

  CaregiverAuthDataBase({this.signInError, this.authMethod});

	CaregiverAuthDataBase copyWith({EmailSignInError? signInError, AuthMethod? authMethod});

	@override
  List<Object?> get props => [signInError, authMethod];
}
