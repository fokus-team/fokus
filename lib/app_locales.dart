import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalesDelegate extends LocalizationsDelegate<AppLocales> {
  const AppLocalesDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pl'].contains(locale.languageCode);
  }

  @override
  Future<AppLocales> load(Locale locale) async {
    AppLocales localizations = new AppLocales(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalesDelegate old) => false;
}

class AppLocales {
  final Locale locale;

  AppLocales(this.locale);

  static AppLocales of(BuildContext context) {
    return Localizations.of<AppLocales>(context, AppLocales);
  }

  static const LocalizationsDelegate<AppLocales> delegate = AppLocalesDelegate();

  Map<String, dynamic> _jsonMap;

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('i18n/${locale.languageCode}_${locale.countryCode}.json');
    _jsonMap = json.decode(jsonString);
    return true;
  }

  String translate(String keyPath) {
    try {
      return keyPath.split('.').fold(_jsonMap, (object, key) => object[key]) as String;
    } on Error catch(_) {
      print('Key $keyPath has no localized string in language ${locale.languageCode}');
      return '';
    }
  }
}