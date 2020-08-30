import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:logging/logging.dart';

import 'active_user_observer.dart';

class NotificationService implements ActiveUserObserver {
	final Logger _logger = Logger('ChildPlansCubit');

	final _firebaseMessaging = FirebaseMessaging();
	static var _notificationPlugin = FlutterLocalNotificationsPlugin();

	NotificationService() {
		_configureNotificationPlugin();
		_configureMessageHandler();
		_printToken();
	}

	void _configureNotificationPlugin() async {
		var initializationSettingsAndroid = AndroidInitializationSettings('ic_stat_name');
		var initializationSettingsIOS = IOSInitializationSettings();
		var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
		await _notificationPlugin.initialize(initializationSettings);
	}

	void _configureMessageHandler() async {
		if (Platform.isIOS) await _requestIOSPermissions();
		_firebaseMessaging.configure(
			onMessage: (Map<String, dynamic> message) async {
				_logger.fine("onMessage: $message");
				await _showNotification(message['notification']['title'], message['notification']['body']);
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

	Future<bool> _requestIOSPermissions() {
		_firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
			_logger.fine("Settings registered: $settings");
		});
		return _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
	}

	static Future<dynamic> _bgMessageHandler(Map<String, dynamic> message) async {
		if (message.containsKey('data')) {
			final data = message['data'];

			final title = data['title'];
			final body = data['message'];

			await _showNotification(title, body);
		}
		if (message.containsKey('notification')) {
			// Handle notification message
			final dynamic notification = message['notification'];
		}
		// Or do other work.
	}

	static Future _showNotification(String title, String message) async {
		var androidPlatformChannelSpecifics = AndroidNotificationDetails('fcm_default_channel', 'Miscellaneous', '', color: Color(0xfdbf00));
		var iOSPlatformChannelSpecifics = IOSNotificationDetails();
		var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
		await _notificationPlugin.show(0, title, message, platformChannelSpecifics);
	}

	void _printToken() async => _logger.info(await _firebaseMessaging.getToken());

  @override
  void onUserSignIn(User user) {

  }

  @override
  void onUserSignOut(User user) {

  }
}
