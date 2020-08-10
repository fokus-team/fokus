import 'package:formz/formz.dart';

enum NameValidationError { invalid }

extension NameValidationErrorTextKey on NameValidationError {
	String get key => const {
		NameValidationError.invalid: '',
	}[this];
}

class Name extends FormzInput<String, NameValidationError> {
	const Name.pure() : super.pure('');
	const Name.dirty([String value = '']) : super.dirty(value);

	@override
	NameValidationError validator(String value) => null;
}
