import 'package:formz/formz.dart';

enum EmailValidationError { invalid }

extension EmailValidationErrorTextKey on EmailValidationError {
	String get key => const {
		EmailValidationError.invalid: 'authentication.error.invalidEmail',
	}[this]!;
}

class Email extends FormzInput<String, EmailValidationError> {
	const Email.pure([String value = '']) : super.pure(value);
	const Email.dirty([String value = '']) : super.dirty(value);

	static final RegExp _emailRegExp = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');

	@override
	EmailValidationError? validator(String? value) => _emailRegExp.hasMatch(value!) ? null : EmailValidationError.invalid;
}
