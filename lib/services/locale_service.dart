import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../model/db/user/user.dart';
import 'app_locales.dart';
import 'observers/user/user_notifier.dart';
import 'observers/user/user_observer.dart';

class LocaleService implements UserObserver {
	final UserNotifier _userNotifier = GetIt.I<UserNotifier>();

	LocaleService() {
		_userNotifier.observeUserChanges(this);
	}

	static Locale parseLocale(String locale) {
		var parts = locale.split('_');
		return Locale(parts[0], parts.length > 1 ? parts[1] : null);
	}

	static Locale? localeSelector(List<Locale>? locales, Iterable<Locale> supportedLocales) => userAwareLocaleSelector();

	static Locale userAwareLocaleSelector([String? userLocale]) {
		if (userLocale != null)
			return parseLocale(userLocale);

		var baseLocales = AppLocalesDelegate.supportedLocales.map((locale) => locale.languageCode).toList();
		for (var locale in WidgetsBinding.instance!.window.locales) {
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
    	setLocale(parseLocale(user.locale!));
  }

  @override
  void onUserSignOut(User user) => setLocale(userAwareLocaleSelector());
}
