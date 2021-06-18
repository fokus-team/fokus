import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

import '../../../model/db/user/user.dart';
import '../../../model/notification/notification_refresh_info.dart';
import '../../../model/ui/app_page.dart';
import '../../../services/app_route_observer.dart';
import '../../../services/notifications/notification_service.dart';
import '../../../services/observers/notification/notification_observer.dart';
import '../../../services/observers/page_foreground_observer.dart';
import '../../../services/observers/user/user_notifier.dart';

part 'stateful_state.dart';

enum StatefulOption {
	resetSubmissionState, noAutoLoading, noDataLoading
}

abstract class StatefulCubit<State extends StatefulState> extends Cubit<State> with NotificationObserver implements RouteAware, PageForegroundObserver {
	final _routeObserver = GetIt.I<AppRouteObserver>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	final UserNotifier _userNotifier = GetIt.I<UserNotifier>();
	@protected
	final List<StatefulOption> options;
	@protected
	bool loadingForFirstTime = true;

  StatefulCubit(ModalRoute pageRoute, {this.options = const [], State? initialState}) :
        super(initialState ?? StatefulState.notLoaded() as State) {
	  onGoToForeground(firstTime: true);
	  if (pageRoute is PageRoute)
	    _routeObserver.subscribe(this, pageRoute);
  }

  @protected
  User? get activeUser => _userNotifier.activeUser;

  Future loadData() async {
	  if (state.loadingInProgress)
	  	return;
	  emit(state.loading() as State);
	  try {
		  await doLoadData();
		  loadingForFirstTime = false;
	  } on Exception {
		  emit(state.withLoadState(DataLoadingState.loadFailure) as State);
		  rethrow;
	  }
  }

  @protected
  Future doLoadData();

	void reload() => emit(state.notLoaded() as State);

	void resetSubmissionState() => emit(state.notSubmitted() as State);

	@override
	@nonVirtual
	void onNotificationReceived(NotificationRefreshInfo info) {
		if (notificationTypeSubscription().contains(info.type) && shouldNotificationRefresh(info))
	    reload();
	}

	bool hasOption(StatefulOption option) => options.contains(option);

	Future submitData({required Future Function() body, State? withState}) async {
		var state = withState ?? this.state;
		if (!state.isNotSubmitted) return;
		emit(state.submit() as State);
		try {
			await body();
		} on Exception {
			emit(state.withSubmitState(DataSubmissionState.submissionFailure) as State);
			rethrow;
		}
	}

	@override
	Future<void> close() {
		_routeObserver.unsubscribe(this);
		return super.close();
	}

	@override
  void onGoToForeground({bool firstTime = false}) {
		if (notificationTypeSubscription().isNotEmpty)
			_notificationService.observeNotifications(this);
		if (!firstTime)
			reload();
  }

	@override
	void onGoToBackground() {
		_notificationService.removeNotificationObserver(this);
	}

  @override
	void didPopNext() => onGoToForeground();

	@override
	void didPop() => onGoToBackground();

	@override
	void didPush() {}

	@override
	void didPushNext() => onGoToBackground();
}
