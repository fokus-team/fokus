import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:googleapis/fcm/v1.dart';
import 'package:logging/logging.dart';
import 'package:fokus/model/db/user/user.dart';

import 'active_user_observer.dart';
import 'data/data_repository.dart';

class NotificationService implements ActiveUserObserver {
	static Logger _logger = Logger('ChildPlansCubit');
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	final _firebaseMessaging = FirebaseMessaging();
	static var _notificationPlugin = FlutterLocalNotificationsPlugin();
	ProjectsMessagesResourceApi _messagesApi;

	User _activeUser;

	NotificationService() {
		_configureNotificationPlugin();
		_configureMessageHandler();
		//_configureFCMApi();
		_printToken();
	}

	Future _configureFCMApi() async => _messagesApi = (await FcmAuthenticator.authenticate()).projects.messages;

	void _configureNotificationPlugin() async {
		var initializationSettingsAndroid = AndroidInitializationSettings('ic_stat_name');
		var initializationSettingsIOS = IOSInitializationSettings();
		var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
		await _notificationPlugin.initialize(initializationSettings);
	}

	void _configureMessageHandler() async {
		if (Platform.isIOS)
			await _requestIOSPermissions();
		_firebaseMessaging.onTokenRefresh.listen(onTokenChanged);
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
		Map<dynamic, dynamic> content;
		if (!message.containsKey('notification')) {
			content = message['data'];
		} else {
			content = message['notification'];
		}
		await _showNotification(content['title'], content['body']);
	}

	static Future _showNotification(String title, String message) async {
		var androidPlatformChannelSpecifics = AndroidNotificationDetails('fcm_default_channel', 'Miscellaneous', '', color: flutter.Color(0xfdbf00));
		var iOSPlatformChannelSpecifics = IOSNotificationDetails();
		var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
		await _notificationPlugin.show(0, title, message, platformChannelSpecifics);
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
