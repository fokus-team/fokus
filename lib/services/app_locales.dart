import 'dart:convert';
import 'dart:ui';
import 'package:fokus/services/observers/current_locale_observer.dart';
import 'package:intl/message_format.dart';
import 'package:logging/logging.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef TranslateFunc = String Function(BuildContext);

class AppLocalesDelegate extends LocalizationsDelegate<AppLocales> {
	const AppLocalesDelegate();

	@override
	bool isSupported(Locale locale) {
		return ['en', 'pl'].contains(locale.languageCode);
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

	Map<String, dynamic> _jsonMap;

	Future<bool> load(Locale locale) async {
		this.locale = locale;
		String jsonString = await rootBundle.loadString('i18n/${locale.languageCode}_${locale.countryCode}.json');
		_jsonMap = json.decode(jsonString);
		_localeObservers.forEach((observer) => observer.onLocaleSet(locale));
		return true;
	}

	String translate(String keyPath, [Map<String, Object> args]) {
		try {
			var string = keyPath.split('.').fold(_jsonMap, (object, key) => object[key]) as String;
			if (args == null)
				return string;
			return MessageFormat(string, locale: locale.toString()).format(args);
		} on NoSuchMethodError {
			_logger.warning('Key $keyPath has no localized string in language ${locale.languageCode}');
			return '';
		} on Error catch (e) {
			_logger.severe('$e');
			return '';
		}
	}

	void observeLocaleChanges(CurrentLocaleObserver observer) => _localeObservers.add(observer);
}
