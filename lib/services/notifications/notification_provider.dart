import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/notification/notification_channel.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/services/observers/data_update_observer.dart';
import 'package:fokus/services/observers/active_user_observer.dart';
import 'package:fokus/services/observers/current_locale_observer.dart';

import 'data_update_notifier.dart';

abstract class NotificationProvider implements ActiveUserObserver, CurrentLocaleObserver, DataUpdateNotifier {
	@protected
	Logger logger = Logger('NotificationProvider');
	@protected
	Future<String> get userToken;
	@protected
	User activeUser;

	Map<NotificationType, Map<Type, DataUpdateObserver>> _dataUpdateObservers = {};

	static var localNotifications = FlutterLocalNotificationsPlugin();

	@protected
	final DataRepository dataRepository = GetIt.I<DataRepository>();

	NotificationProvider()  {
		if (Platform.isAndroid)
			AppLocales.instance.observeLocaleChanges(this);
	}

	@protected
	void onNotificationReceived(NotificationType type) => _dataUpdateObservers[type]?.values?.forEach((observer) => observer.onDataUpdated(type));
	@override
	void observeDataUpdates(DataUpdateObserver observer) => observer.dataTypeSubscription().forEach((type) => (_dataUpdateObservers[type] ??= {})[observer.runtimeType] = observer);
	@override
	void removeDataUpdateObserver(DataUpdateObserver observer) => observer.dataTypeSubscription().forEach((type) => _dataUpdateObservers[type].remove(observer.runtimeType));

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
		dataRepository.removeNotificationID(token);
		dataRepository.insertNotificationID(activeUser.id, token);
	}

	@protected
	void removeUserToken(String token) async => dataRepository.removeNotificationID(token, userId: activeUser.id);

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
