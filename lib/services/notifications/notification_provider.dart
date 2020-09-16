import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fokus/model/notification/notification_channel.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/observers/active_user_observer.dart';
import 'package:fokus/services/observers/current_locale_observer.dart';

abstract class NotificationProvider implements ActiveUserObserver, CurrentLocaleObserver {
	@protected
	Logger logger = Logger('NotificationProvider');
	@protected
	Future<String> get userToken;
	@protected
	User activeUser;

	static var localNotifications = FlutterLocalNotificationsPlugin();

	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	NotificationProvider()  {
		if (Platform.isAndroid)
			AppLocales.instance.observeLocaleChanges(this);
	}

  @override
	void onUserSignIn(User user) async {
		activeUser = user;
		logger.info('sign in ${await userToken}');
		addUserToken(await userToken);
	}

	@override
	void onUserSignOut(User user) async {
		removeUserToken(await userToken);
		activeUser = null;
	}

	@protected
	void addUserToken(String token) async {
		if (token == null)
			return;
		_dataRepository.removeNotificationID(token);
		_dataRepository.insertNotificationID(activeUser.id, token);
	}

	@protected
	void removeUserToken(String token) async => _dataRepository.removeNotificationID(token, userId: activeUser.id);

	@override
  void onLocaleSet(Locale locale) {
		var androidPlugin = localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
		var translate = (String key) => AppLocales.instance.translate(key);
		for (var channelType in NotificationChannel.values) {
			var androidChannel = AndroidNotificationChannel(channelType.id, translate(channelType.nameKey),
					translate(channelType.descriptionKey), channelAction: AndroidNotificationChannelAction.Update);
			androidPlugin.createNotificationChannel(androidChannel);
		}
  }
}
