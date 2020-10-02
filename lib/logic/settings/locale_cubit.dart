import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/services/observers/current_locale_observer.dart';

class LocaleCubit extends Cubit<LocaleState> {
	final CurrentLocaleObserver _localeObserver;

	static const String defaultLanguageKey = 'default';
	static final AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();

  LocaleCubit(this._localeObserver) : super(LocaleState(_getLocaleCode()));

  void setLocale({Locale locale, bool setDefault = false}) {
  	if (setDefault) {
			_appConfigRepository.unsetUserLanguage();
		  locale = _selectLocale();
	  } else
	  	_appConfigRepository.setUserLanguage(locale);
	  if (locale != AppLocales.instance.locale) {
		  AppLocales.instance.setLocale(locale);
		  _localeObserver.onLocaleSet(locale);
	  }
	  emit(LocaleState(_getLocaleCode()));
  }

  static String _getLocaleCode() => _appConfigRepository.isUserLanguageSet() ? '${_parseLocale(_appConfigRepository.getUserLanguage())}' : defaultLanguageKey;

	Locale _selectLocale() => localeSelector(WidgetsBinding.instance.window.locales, AppLocalesDelegate.supportedLocales);

	static Locale _parseLocale(String locale) {
		List<String> parts = locale.split('_');
		return Locale(parts[0], parts.length > 1 ? parts[1] : null);
	}

	static Locale localeSelector(List<Locale> locales, Iterable<Locale> supportedLocales) {
		var userLanguage = _appConfigRepository.getUserLanguage();
		if (userLanguage != null)
			return _parseLocale(userLanguage);

		List<String> baseLocales = supportedLocales.map((locale) => locale.languageCode).toList();
		for (var locale in locales) {
			if (supportedLocales.contains(locale))
				return locale;
			var languageMatch = baseLocales.indexWhere((baseLocale) => baseLocale == locale.languageCode);
			if (languageMatch >= 0)
				return AppLocalesDelegate.supportedLocales[languageMatch];
		}
		return AppLocalesDelegate.supportedLocales[0];
	}
}

class LocaleState extends Equatable {
	final String languageKey;

  LocaleState(this.languageKey);

	@override
	List<Object> get props => [languageKey];
}
