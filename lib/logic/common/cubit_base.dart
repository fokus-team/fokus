import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:bloc_extensions/bloc_extensions.dart';

import '../../model/db/user/user.dart';
import '../../model/notification/notification_refresh_info.dart';
import '../../services/app_route_observer.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/observers/notification/notification_observer.dart';
import '../../services/observers/user/user_notifier.dart';

enum StatefulOption {
	noAutoLoading
}

abstract class CubitBase<CubitData extends Equatable> extends ReloadableCubit<StatefulState<CubitData>> with NotificationObserver, StatefulCubit {
	@override
	final routeObserver = GetIt.I<AppRouteObserver>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	final UserNotifier _userNotifier = GetIt.I<UserNotifier>();

	@protected
	final List<StatefulOption> options;
	@protected
	User? get activeUser => _userNotifier.activeUser;

	CubitBase(ModalRoute pageRoute, {this.options = const []}) : super(initialState: StatefulState(), route: pageRoute);

	@override
	@nonVirtual
	void onNotificationReceived(NotificationRefreshInfo info) {
		if (notificationTypeSubscription().contains(info.type) && shouldNotificationRefresh(info))
			reload(ReloadReason.other);
	}

	@override
	Future reload(_) => Future.value(state.copyWith(loadingState: DataLoadingState.loadSuccess));

	bool hasOption(StatefulOption option) => options.contains(option);

	@override
  void show(ReloadReason reason) {
		if (notificationTypeSubscription().isNotEmpty)
			_notificationService.observeNotifications(this);
		if (!hasOption(StatefulOption.noAutoLoading))
			super.show(reason);
  }

	@override
	void hide() => _notificationService.removeNotificationObserver(this);
}
