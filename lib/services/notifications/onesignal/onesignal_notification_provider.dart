import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/notification/notification_data.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/utils/snackbar_utils.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/services/notifications/notification_provider.dart';


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

	void _onNotificationOpened(OSNotificationOpenedResult result) async {
		logger.fine("onOpenMessage: $result");
		var navigate = (AppPage page, [dynamic arguments]) => _navigatorKey.currentState.pushNamed(page.name, arguments: arguments);
		var context = _navigatorKey.currentState.context;
		var data = NotificationData.fromJson(result.notification.payload.additionalData);
		var activeUser = context.bloc<AuthenticationBloc>().state.user;
		if (activeUser == null || activeUser.id != data.recipient) {
			if (activeUser == null)
				navigate(data.type.recipient.signInPage);
			showFailSnackbar(context, 'authentication.signInPrompt');
			return;
		}
		dynamic arguments = data.subject;
		if (data.type.redirectPage == AppPage.planInstanceDetails) {
			//arguments = UIPlanInstance.fromDBModel(await dataRepository.getPlanInstance(taskInstanceId: data.subject), );
			navigate(data.type.redirectPage, arguments);
			return;
		} else if (data.type.redirectPage == AppPage.caregiverChildDashboard) {
			arguments = Map<String, dynamic>();
			arguments['tab'] = data.type == NotificationType.rewardBought ? 1 : 0;
			if (data.subject != null)
				arguments['id'] = data.subject;
		}
		navigate(data.type.redirectPage, arguments);
	}

  void _configureNotificationHandlers() {
	  OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
		  logger.fine("onMessage: $notification");
	  });
	  OneSignal.shared.setNotificationOpenedHandler(_onNotificationOpened);
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
