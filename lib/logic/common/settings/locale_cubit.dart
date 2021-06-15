import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/services/locale_service.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/utils/definitions.dart';

class LocaleCubit extends Cubit<LocaleState> {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authenticationBloc;
	
	static const String defaultLanguageKey = 'default';
	final LocaleService _localeProvider = GetIt.I<LocaleService>();
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

  LocaleCubit(this._activeUser, this._authenticationBloc) : super(LocaleState(_getLocaleCode(_activeUser().locale)));

  void setLocale({Locale? locale, bool setDefault = false}) {
  	var activeUser = _activeUser();
	  if (setDefault) {
		  locale = LocaleService.userAwareLocaleSelector();
		  _dataRepository.updateUser(activeUser.id!, locale: '');
	  } else
		  _dataRepository.updateUser(activeUser.id!, locale: '$locale');
	  var userLocale = setDefault ? null : '$locale';
  	if (_localeProvider.setLocale(locale!))
			_authenticationBloc.add(AuthenticationActiveUserUpdated.fromLocale(activeUser, userLocale));
	  emit(LocaleState(_getLocaleCode(userLocale)));
  }

  static String _getLocaleCode(String? userLocale) => userLocale != null ? '${LocaleService.parseLocale(userLocale)}' : defaultLanguageKey;
}

class LocaleState extends Equatable {
	final String languageKey;

  LocaleState(this.languageKey);

	@override
	List<Object?> get props => [languageKey];
}
