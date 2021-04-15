import 'package:formz/formz.dart';

enum NameValidationError { empty }

extension NameValidationErrorTextKey on NameValidationError {
	String get key => const {
		NameValidationError.empty: 'authentication.error.nameEmpty',
	}[this]!;
}

class Name extends FormzInput<String, NameValidationError> {
	const Name.pure([String value = '']) : super.pure(value);
	const Name.dirty([String value = '']) : super.dirty(value);

	@override
	NameValidationError? validator(String? value) => value!.isEmpty ? NameValidationError.empty : null;
}
