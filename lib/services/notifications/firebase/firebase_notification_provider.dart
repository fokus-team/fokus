import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fokus/model/notification/notification_text.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:googleapis/fcm/v1.dart';
import 'package:fokus_auth/fokus_auth.dart';

import 'package:fokus/model/notification/notification_channel.dart';
import 'package:fokus/services/app_locales.dart';

import '../notification_provider.dart';

class FirebaseNotificationProvider extends NotificationProvider {
	final _firebaseMessaging = FirebaseMessaging();
	ProjectsMessagesResourceApi notificationApi;

	FirebaseNotificationProvider() {
		_configureLocalNotifications();
		_configureFirebaseMessaging();
		_configureFCMApi();
	}

	void _configureLocalNotifications() async {
		var initializationSettingsAndroid = AndroidInitializationSettings('ic_stat_name');
		var initializationSettingsIOS = IOSInitializationSettings();
		var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
		await NotificationProvider.localNotifications.initialize(initializationSettings);
	}

	void _configureFirebaseMessaging() async {
		if (Platform.isIOS)
			await _requestIOSPermissions();
		_firebaseMessaging.onTokenRefresh.listen((token) => activeUser != null ? addUserToken(token) : {});
		_firebaseMessaging.configure(
			onMessage: (Map<String, dynamic> message) async {
				logger.fine("onMessage: $message");
				await _showNotification(message);
			},
			onBackgroundMessage: _bgMessageHandler,
			onLaunch: (Map<String, dynamic> message) async {
				logger.fine("onLaunch: $message");
			},
			onResume: (Map<String, dynamic> message) async {
				logger.fine("onResume: $message");
			},
		);
	}

	Future _configureFCMApi() async => notificationApi = (await FcmAuthenticator.authenticate()).projects.messages;

	Future<bool> _requestIOSPermissions() {
		_firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
			logger.fine("Settings registered: $settings");
		});
		return _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
	}

	static Future<dynamic> _bgMessageHandler(Map<String, dynamic> message) async {
		await _showNotification(message);
	}

	static Future _showNotification(Map<String, dynamic> message) async {
		var translate = (String key) => AppLocales.instance.translate(key);
		var locTranslate = (NotificationText text) => AppLocales.instance.translate(text.key, text.arguments);

		var channel = NotificationChannel.general;
		if (message['data']['channel'] != null)
			channel = NotificationChannel.values[int.parse(message['data']['channel'])];

		String parse(String field) {
			var text = message['notification'][field];
			if (message['data']['${field}Key'] != null)
				text = locTranslate(NotificationText.fromJson(field, message['data']));
			return text;
		}
		var androidPlatformChannelSpecifics = AndroidNotificationDetails(channel.id, translate(channel.nameKey), translate(channel.descriptionKey), color: AppColors.notificationAccentColor);
		var iOSPlatformChannelSpecifics = IOSNotificationDetails();
		var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
		await NotificationProvider.localNotifications.show(0, parse('title'), parse('body'), platformChannelSpecifics);
	}

  @override
  Future<String> get userToken async => await _firebaseMessaging.getToken();
}
