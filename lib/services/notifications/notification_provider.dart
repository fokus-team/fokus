import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fokus/model/ui/localized_text.dart';
import 'package:get_it/get_it.dart';
import 'package:googleapis/fcm/v1.dart';
import 'package:logging/logging.dart';
import 'package:fokus_auth/fokus_auth.dart';

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/services/observers/active_user_observer.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/notification_channel.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/services/observers/current_locale_observer.dart';

class NotificationProvider implements ActiveUserObserver, CurrentLocaleObserver {
	static Logger _logger = Logger('NotificationProvider');
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	final _firebaseMessaging = FirebaseMessaging();
	static var _localNotifications = FlutterLocalNotificationsPlugin();
	ProjectsMessagesResourceApi notificationApi;

	User _activeUser;

	NotificationProvider() {
		_configureLocalNotifications();
		_configureFirebaseMessaging();
		_configureFCMApi();
		_printToken();
	}

	void _configureLocalNotifications() async {
		var initializationSettingsAndroid = AndroidInitializationSettings('ic_stat_name');
		var initializationSettingsIOS = IOSInitializationSettings();
		var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
		await _localNotifications.initialize(initializationSettings);
		if (Platform.isAndroid)
			AppLocales.instance.observeLocaleChanges(this);
	}

	@override
	void onLocaleSet(flutter.Locale locale) {
		var androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
		var translate = (String key) => AppLocales.instance.translate(key);
		for (var channelType in NotificationChannel.values) {
			var androidChannel = AndroidNotificationChannel(channelType.id, translate(channelType.nameKey),
					translate(channelType.descriptionKey), channelAction: AndroidNotificationChannelAction.Update);
			androidPlugin.createNotificationChannel(androidChannel);
		}
	}

	void _configureFirebaseMessaging() async {
		if (Platform.isIOS)
			await _requestIOSPermissions();
		_firebaseMessaging.onTokenRefresh.listen(onTokenChanged);
		_firebaseMessaging.configure(
			onMessage: (Map<String, dynamic> message) async {
				_logger.fine("onMessage: $message");
				await _showNotification(message);
			},
			onBackgroundMessage: _bgMessageHandler,
			onLaunch: (Map<String, dynamic> message) async {
				_logger.fine("onLaunch: $message");
			},
			onResume: (Map<String, dynamic> message) async {
				_logger.fine("onResume: $message");
			},
		);
	}

	Future _configureFCMApi() async => notificationApi = (await FcmAuthenticator.authenticate()).projects.messages;

	Future<bool> _requestIOSPermissions() {
		_firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
			_logger.fine("Settings registered: $settings");
		});
		return _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
	}

	static Future<dynamic> _bgMessageHandler(Map<String, dynamic> message) async {
		Map<dynamic, dynamic> content;
		if (!message.containsKey('notification')) {
			content = message['data'];
		} else {
			content = message['notification'];
		}
		//await _showNotification(content['title'], content['body'], message['data']['channel']);
	}

	static Future _showNotification(Map<String, dynamic> message) async {
		var translate = (String key) => AppLocales.instance.translate(key);
		var locTranslate = (LocalizedText text) => AppLocales.instance.translate(text.key, text.arguments);

		var channel = NotificationChannel.general;
		if (message['data']['channel'] != null)
			channel = NotificationChannel.values[int.parse(message['data']['channel'])];

		String parse(String field) {
			var text = message['notification'][field];
			if (message['data']['${field}Key'] != null)
				text = locTranslate(LocalizedText.fromJson(field, message['data']));
			return text;
		}
		var androidPlatformChannelSpecifics = AndroidNotificationDetails(channel.id, translate(channel.nameKey), translate(channel.descriptionKey), color: flutter.Color(0xfdbf00));
		var iOSPlatformChannelSpecifics = IOSNotificationDetails();
		var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
		await _localNotifications.show(0, parse('title'), parse('body'), platformChannelSpecifics);
	}

	void _printToken() async => _logger.info(await _firebaseMessaging.getToken());

	void onTokenChanged(String token) {
		if (_activeUser != null)
			_addUserToken(token);
	}

  @override
  void onUserSignIn(User user) async {
		_activeUser = user;
		_addUserToken(await _firebaseMessaging.getToken());
  }

  @override
  void onUserSignOut(User user) async {
	  _dataRepository.removeNotificationID(await _firebaseMessaging.getToken(), userId: _activeUser.id);
		_activeUser = null;
  }

  void _addUserToken(String token) async {
	  _dataRepository.removeNotificationID(token);
    _dataRepository.insertNotificationID(_activeUser.id, token);
  }
}
