import 'package:fokus/model/ui/auth/password.dart';
import 'package:formz/formz.dart';

enum RepeatedPasswordValidationError { noPasswordMatch }

extension RepeatedPassErrorTextKey on RepeatedPasswordValidationError {
	String get key => const {
		RepeatedPasswordValidationError.noPasswordMatch: 'authentication.noPasswordMatch',
	}[this];
}

class ConfirmedPassword extends FormzInput<String, RepeatedPasswordValidationError> {

	final Password original;

	const ConfirmedPassword.pure() : original = const Password.pure(), super.pure('');
	const ConfirmedPassword.dirty({this.original, String value}) : super.dirty(value);

	ConfirmedPassword copyWith({Password original, String value}) {
		return ConfirmedPassword.dirty(
			original: original ?? this.original,
			value: value ?? this.value
		);
	}

	@override
  bool operator ==(Object other) {
		return super==(other) && other is ConfirmedPassword &&  original == other.original;
  }

	@override
	int get hashCode => super.hashCode ^ original.hashCode;

  @override
	RepeatedPasswordValidationError validator(String value) => value == original?.value ? null : RepeatedPasswordValidationError.noPasswordMatch;
}
