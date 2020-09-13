import 'dart:convert';
import 'dart:ui';
import 'package:fokus/services/observers/current_locale_observer.dart';
import 'package:intl/message_format.dart';
import 'package:logging/logging.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef TranslateFunc = String Function(BuildContext);

class AppLocalesDelegate extends LocalizationsDelegate<AppLocales> {
	static List<Locale> supportedLocales = [
		const Locale('en', 'US'),
		const Locale('pl', 'PL')
	];

	const AppLocalesDelegate();

	@override
	bool isSupported(Locale locale) {
		return supportedLocales.contains(locale);
	}

	@override
	Future<AppLocales> load(Locale locale) async {
		await AppLocales.instance.load(locale);
		return AppLocales.instance;
	}

	@override
	bool shouldReload(AppLocalesDelegate old) => false;
}

class AppLocales {
	final Logger _logger = Logger('AppLocales');
	Locale locale;
	List<CurrentLocaleObserver> _localeObservers = [];

	static AppLocales instance = AppLocales();
	static AppLocales of(BuildContext context) => Localizations.of<AppLocales>(context, AppLocales);

	static const LocalizationsDelegate<AppLocales> delegate = AppLocalesDelegate();

	Map<Locale, Map<String, dynamic>> _translations = {};

	Future<bool> load(Locale locale) async {
		this.locale = locale;
		if (_translations.isEmpty)
			for (var locale in AppLocalesDelegate.supportedLocales) {
				String localeTranslations = await rootBundle.loadString('i18n/$locale.json');
				_translations[locale] = json.decode(localeTranslations);
			}
		_localeObservers.forEach((observer) => observer.onLocaleSet(locale));
		return true;
	}

	String translate(String key, [Map<String, Object> args]) {
		try {
			var string = key.split('.').fold(_translations[locale], (object, key) => object[key]) as String;
			if (args == null)
				return string;
			return MessageFormat(string, locale: locale.toString()).format(args);
		} on NoSuchMethodError {
			_logger.warning('Key $key has no localized string in language ${locale.languageCode}');
			return '';
		} on Error catch (e) {
			_logger.severe('$e');
			return '';
		}
	}

	Map<String, String> getTranslations(String key, [Map<String, Object> args]) {
		Map<String, String> translations = {};
		for (var locale in AppLocalesDelegate.supportedLocales)
			translations[locale.languageCode] = translate(key, args);
		return translations;
	}

	void observeLocaleChanges(CurrentLocaleObserver observer) => _localeObservers.add(observer);
}
