import '../services/app_locales.dart';

const int _minPasswordLength = 6;
const String _errorKey = 'authentication.error';

final RegExp _emailRegExp = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');
final _lengthRegExp = RegExp(r'^[A-Za-z\d]{' '$_minPasswordLength' r',}$');

String? validateEmail(String? email) => _emailRegExp.hasMatch(email!) ? null : AppLocales.instance.translate('$_errorKey.invalidEmail');
String? validateName(String? name) => name!.isNotEmpty ? null : AppLocales.instance.translate('$_errorKey.nameEmpty');
String? validateAgreement(bool? value) => value! ? null : AppLocales.instance.translate('$_errorKey.agreementNotAccepted');

String? validatePassword(String? value, {bool fullValidation = false}) {
  if(value == null || value.isEmpty)
    return AppLocales.instance.translate('$_errorKey.passwordEmpty');
  if(!fullValidation)
    return null;
  if (!_lengthRegExp.hasMatch(value))
    return AppLocales.instance.translate('$_errorKey.passwordNotLongEnough', {'LENGTH': _minPasswordLength});
  return null;
}

String? validateConfirmPassword({String? value, String? original}) {
  if (value == original) return null;
  return AppLocales.instance.translate('$_errorKey.noPasswordMatch');
}
