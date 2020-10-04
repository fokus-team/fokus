import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/services/observers/active_user_observer.dart';

import 'app_locales.dart';

class LocaleProvider implements ActiveUserObserver {
	static Locale parseLocale(String locale) {
		List<String> parts = locale.split('_');
		return Locale(parts[0], parts.length > 1 ? parts[1] : null);
	}

	static Locale localeSelector(List<Locale> locales, Iterable<Locale> supportedLocales) => userAwareLocaleSelector();

	static Locale userAwareLocaleSelector([String userLocale]) {
		if (userLocale != null)
			return parseLocale(userLocale);

		List<String> baseLocales = AppLocalesDelegate.supportedLocales.map((locale) => locale.languageCode).toList();
		for (var locale in WidgetsBinding.instance.window.locales) {
			if (AppLocalesDelegate.supportedLocales.contains(locale))
				return locale;
			var languageMatch = baseLocales.indexWhere((baseLocale) => baseLocale == locale.languageCode);
			if (languageMatch >= 0)
				return AppLocalesDelegate.supportedLocales[languageMatch];
		}
		return AppLocalesDelegate.supportedLocales[0];
	}

	bool setLocale(Locale locale) {
		var willChange = locale != AppLocales.instance.locale;
		if (willChange)
			AppLocales.instance.setLocale(locale);
		return willChange;
	}

  @override
  void onUserSignIn(User user) {
    if (user.locale != null)
    	setLocale(parseLocale(user.locale));
  }

  @override
  void onUserSignOut(User user) => setLocale(userAwareLocaleSelector());
}
