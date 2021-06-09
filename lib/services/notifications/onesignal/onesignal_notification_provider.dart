import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/navigation/child_dashboard_params.dart';
import 'package:fokus/model/navigation/plan_instance_params.dart';
import 'package:fokus/utils/navigation_utils.dart';
import 'package:fokus/model/notification/notification_data.dart';
import 'package:fokus/services/app_route_observer.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/services/ui_data_aggregator.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/services/notifications/notification_provider.dart';


class OneSignalNotificationProvider extends NotificationProvider {
	final String appId = Foundation.kReleaseMode ? 'ed3ee23f-aa7a-4fc7-91ab-9967fa7712e5' : 'f82c17d5-95cb-48ef-b8dc-ca8a95406221';

	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();
  final _routeObserver = GetIt.I<AppRouteObserver>();

	OneSignalNotificationProvider() {
		_configureOneSignal();
		_configureNotificationHandlers();
	}

	void _configureOneSignal() async {
		OneSignal.shared.setLogLevel(Foundation.kReleaseMode ? OSLogLevel.error : OSLogLevel.warn, OSLogLevel.none);
		OneSignal.shared.setAppId(appId);
		await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
	}

	void _onNotificationOpened(OSNotificationOpenedResult result) async {
		if (result.notification.additionalData == null)
			return;
    await _routeObserver.navigatorInitialized;
		logger.fine("onOpenMessage: $result");
    var context = _navigatorKey.currentState!.context;

		var data = NotificationData.fromJson(result.notification.additionalData!);
		var activeUser = BlocProvider.of<AuthenticationBloc>(context).state.user;
		if (activeUser == null || activeUser.id != data.recipient) {
			if (activeUser == null)
				navigateChecked(context, data.type.recipient.signInPage);
			showFailSnackbar(context, 'authentication.signInPrompt');
			return;
		}
		dynamic arguments = data.subject;
		// TODO Check if navigateChecked will work with popup-route on top of page being pushed?
		if (data.type.redirectPage == AppPage.planInstanceDetails) {
			arguments = await _dataAggregator.loadPlanInstance(planInstanceId: data.subject);
			_navigatorKey.currentState!.pushNamed(data.type.redirectPage.name, arguments: PlanInstanceParams(planInstance: arguments));
			return;
		} else if (data.type.redirectPage == AppPage.caregiverChildDashboard) {
			navigateChecked(context, data.type.redirectPage, arguments: ChildDashboardParams(
				tab: data.type == NotificationType.rewardBought ? 1 : 0,
				child: await _dataAggregator.loadChild(data.sender),
				id: data.subject
			));
		} else
      navigateChecked(context, data.type.redirectPage, arguments: arguments);
	}

  void _configureNotificationHandlers() {
	  OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) async {
	  	if (event.notification.additionalData == null) {
			  event.complete(event.notification);
	  		return;
		  }
      await _routeObserver.navigatorInitialized;
		  logger.fine("onMessage: ${event.notification}");
		  var context = _navigatorKey.currentState!.context;
		  var data = NotificationData.fromJson(event.notification.additionalData!);
		  var activeUser = BlocProvider.of<AuthenticationBloc>(context).state.user;
		  if (activeUser == null || activeUser.id != data.recipient){
			  event.complete(event.notification);
			  return;
		  }
		  var authBloc = BlocProvider.of<AuthenticationBloc>(context);
		  if (data.type == NotificationType.badgeAwarded) {
			  Child user = await dataRepository.getUser(id: activeUser.id, fields: ['badges']) as Child;
			  authBloc.add(AuthenticationActiveUserUpdated(UIChild.from(activeUser as UIChild, badges: user.badges)));
		  } else if (data.type == NotificationType.taskApproved) {
			  Child user = await dataRepository.getUser(id: activeUser.id, fields: ['points']) as Child;
			  authBloc.add(AuthenticationActiveUserUpdated(UIChild.from(activeUser as UIChild, points: List.from(user.points!))));
		  }
		  onNotificationReceived(data);
		  event.complete(event.notification);
	  });
	  OneSignal.shared.setNotificationOpenedHandler(_onNotificationOpened);
	  OneSignal.shared.setSubscriptionObserver((changes) {
	  	if (activeUser == null)
	  		return;
		  if (changes.from.userId != null) {
				logger.info('removing ${changes.from.userId}');
			  removeUserToken(changes.from.userId!);
		  }
		  if (changes.to.userId != null) {
			  logger.info('adding ${changes.to.userId}');
			  addUserToken(changes.to.userId!);
		  }
	  });
  }

  @override
  Future<String?> get userToken async => (await OneSignal.shared.getDeviceState())?.userId;
}
