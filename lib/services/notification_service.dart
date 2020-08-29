import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';

class NotificationService {
	final Logger _logger = Logger('ChildPlansCubit');

	final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

	NotificationService() {
		_configureMessageHandler();
		_printToken();
	}

	void _configureMessageHandler() async {
		if (Platform.isIOS) await _requestIOSPermissions();
		_firebaseMessaging.configure(
			onMessage: (Map<String, dynamic> message) async {
				_logger.fine("onMessage: $message");
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
			// Handle data message
			final dynamic data = message['data'];
		}
		if (message.containsKey('notification')) {
			// Handle notification message
			final dynamic notification = message['notification'];
		}
		// Or do other work.
	}

	void _printToken() async => _logger.info(await _firebaseMessaging.getToken());
}
