import 'package:formz/formz.dart';

enum AgreementValidationError { invalid }

extension AgreementValidationErrorTextKey on AgreementValidationError {
	String get key => const {
		AgreementValidationError.invalid: 'authentication.error.agreementNotAccepted',
	}[this];
}

class Agreement extends FormzInput<bool, AgreementValidationError> {
	const Agreement.pure([bool value = false]) : super.pure(value);
	const Agreement.dirty([bool value = false]) : super.dirty(value);

	@override
	AgreementValidationError validator(bool value) => value ? null : AgreementValidationError.invalid;
}
