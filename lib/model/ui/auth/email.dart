import 'package:formz/formz.dart';

enum EmailValidationError { invalid }

extension EmailValidationErrorTextKey on EmailValidationError {
	String get key => const {
		EmailValidationError.invalid: 'authentication.invalidEmail',
	}[this];
}

class Email extends FormzInput<String, EmailValidationError> {
	const Email.pure() : super.pure('');
	const Email.dirty([String value = '']) : super.dirty(value);

	static final RegExp _emailRegExp = RegExp('^[a-zA-Z0-9.!#\$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$');

	@override
	EmailValidationError validator(String value) => _emailRegExp.hasMatch(value) ? null : EmailValidationError.invalid;
}
