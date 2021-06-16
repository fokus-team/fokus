import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../../model/db/user/user.dart';
import '../../model/notification/notification_channel.dart';
import '../../model/notification/notification_refresh_info.dart';
import '../app_locales.dart';
import '../data/data_repository.dart';
import '../observers/current_locale_observer.dart';
import '../observers/notification/notification_notifier.dart';
import '../observers/notification/notification_observer.dart';
import '../observers/user/user_observer.dart';

abstract class NotificationProvider implements UserObserver, CurrentLocaleObserver, NotificationNotifier {
	@protected
	Logger logger = Logger('NotificationProvider');
	@protected
	Future<String?> get userToken;
	@protected
	User? activeUser;

	final Map<Type, NotificationObserver> _notificationObservers = {};

	static FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

	@protected
	final DataRepository dataRepository = GetIt.I<DataRepository>();

	NotificationProvider()  {
		if (Platform.isAndroid)
			AppLocales.instance.observeLocaleChanges(this);
	}

	@protected
	void onNotificationReceived(NotificationRefreshInfo info) => _notificationObservers.forEach((_, observer) => observer.onNotificationReceived(info));
	@override
	void observeNotifications(NotificationObserver observer) => _notificationObservers[observer.runtimeType] = observer;
	@override
	void removeNotificationObserver(NotificationObserver observer) => _notificationObservers.remove(observer.runtimeType);

  @override
	void onUserSignIn(User? user) async {
  	if (user == null)
  		return;
		activeUser = user;
	  var token = await userToken;
		logger.info('sign in $token');
		if (token != null)
			addUserToken(token);
	}

	@override
	void onUserSignOut(User user) async {
  	var token = await userToken;
	  if (token != null)
		  removeUserToken(token);
		activeUser = null;
	}

	@protected
	void addUserToken(String token) async {
		if (activeUser == null)
			return;
		dataRepository.removeNotificationID(token);
		dataRepository.insertNotificationID(activeUser!.id!, token);
	}

	@protected
	void removeUserToken(String token) async => dataRepository.removeNotificationID(token, userId: activeUser!.id);

	@override
  void onLocaleSet(Locale locale) {
		if (!Platform.isAndroid)
			return;
		var androidPlugin = localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
		translate(String key) => AppLocales.instance.translate(key);
		for (var channelType in NotificationChannel.values) {
			var androidChannel = AndroidNotificationChannel(channelType.id, translate(channelType.nameKey),
					translate(channelType.descriptionKey), channelAction: AndroidNotificationChannelAction.update);
			androidPlugin!.createNotificationChannel(androidChannel);
		}
  }
}
