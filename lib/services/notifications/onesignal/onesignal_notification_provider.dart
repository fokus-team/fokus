import 'package:flutter/widgets.dart';
import 'package:fokus/model/notification/notification_data.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/services/notifications/notification_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


class OneSignalNotificationProvider extends NotificationProvider {
	final String appId = 'ed3ee23f-aa7a-4fc7-91ab-9967fa7712e5';
	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();

	OneSignalNotificationProvider() {
		_configureOneSignal();
		_configureNotificationHandlers();
	}

	void _configureOneSignal() async {
		OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
		OneSignal.shared.init(
			appId,
			iOSSettings: {
				OSiOSSettings.autoPrompt: false,
				OSiOSSettings.inAppLaunchUrl: false
			}
		);
		OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
		await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
	}

  void _configureNotificationHandlers() {
	  OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
		  logger.fine("onMessage: $notification");
	  });
	  OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
		  logger.fine("onOpenMessage: $result");
		  var data = NotificationData.fromJson(result.notification.payload.additionalData);
		  dynamic arguments = data.subject;
			if (data.type.redirectPage == AppPage.caregiverChildDashboard) {
				arguments = {'tab': data.type == NotificationType.rewardBought ? 1 : 0};
				if (data.subject != null)
					arguments['id'] = data.subject;
			} else if (data.subject != null)
				arguments = data.subject;
			_navigatorKey.currentState.pushNamed(data.type.redirectPage.name, arguments: arguments);
	  });
	  OneSignal.shared.setSubscriptionObserver((changes) {
	  	if (activeUser == null)
	  		return;
		  if (changes.from.userId != null && changes.to.userId == null) {
				logger.info('removing ${changes.from.userId}');
			  removeUserToken(changes.to.userId);
		  }
		  if (changes.from.userId == null && changes.to.userId != null) {
			  logger.info('adding ${changes.to.userId}');
			  addUserToken(changes.to.userId);
		  }
	  });
  }

  @override
  Future<String> get userToken async => (await OneSignal.shared.getPermissionSubscriptionState()).subscriptionStatus.userId;
}
