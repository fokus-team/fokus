import 'package:flutter/material.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/utils/app_locales.dart';

String helpPagePath(BuildContext context, String helpPage) {
	return 'assets/help/' + AppLocales.of(context).locale.languageCode + '/' + helpPage + '.md';
}

String currencySvgPath(CurrencyType currencyType) {
	return 'assets/image/currency/${currencyType.toString().split('.').last}.svg';
}
