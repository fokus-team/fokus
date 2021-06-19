import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

import '../../../model/db/user/user.dart';
import '../../../model/notification/notification_refresh_info.dart';
import '../../../services/app_route_observer.dart';
import '../../../services/notifications/notification_service.dart';
import '../../../services/observers/notification/notification_observer.dart';
import '../../../services/observers/page_foreground_observer.dart';
import '../../../services/observers/user/user_notifier.dart';

part 'stateful_state.dart';

enum StatefulOption {
	resetSubmissionState, noAutoLoading, noDataLoading
}

abstract class StatefulCubit<CubitData extends Equatable> extends Cubit<StatefulState<CubitData>> with NotificationObserver implements RouteAware, PageForegroundObserver {
	final _routeObserver = GetIt.I<AppRouteObserver>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	final UserNotifier _userNotifier = GetIt.I<UserNotifier>();

	@protected
	final List<StatefulOption> options;
	@protected
	bool loadingForFirstTime = true;
	@protected
	User? get activeUser => _userNotifier.activeUser;
	@protected
	CubitData? get data => state.data;

  StatefulCubit(ModalRoute pageRoute, {this.options = const []}) : super(StatefulState()) {
	  if (pageRoute is PageRoute)
	    _routeObserver.subscribe(this, pageRoute);
  }

	@protected
  Future doLoad({required FutureOr<CubitData?> Function() body, CubitData? initial}) async {
	  if (state.beingLoaded) return;
	  emit(state.copyWith(loadingState: DataLoadingState.loadingInProgress, data: initial));
	  try {
		  emit(state.copyWith(data: await body(), loadingState: DataLoadingState.loadSuccess));
		  loadingForFirstTime = false;
	  } on Exception {
		  emit(state.copyWith(loadingState: DataLoadingState.loadFailure));
		  rethrow;
	  }
  }

	@protected
	Future submit({required FutureOr<CubitData?> Function() body, CubitData? initial}) async {
		if (!state.notSubmitted) return;
		emit(state.copyWith(submissionState: DataSubmissionState.submissionInProgress, data: initial));
		try {
			emit(state.copyWith(data: await body(), submissionState: DataSubmissionState.submissionSuccess));
		} on Exception {
			emit(state.copyWith(submissionState: DataSubmissionState.submissionFailure));
			rethrow;
		}
	}

	@protected
  Future load() => Future.value(state.copyWith(submissionState: DataSubmissionState.submissionSuccess));
  @protected
  void update(CubitData data) => emit(state.copyWith(data: data));

	void resetSubmissionState() => emit(state.copyWith(submissionState: DataSubmissionState.notSubmitted));

	@override
	@nonVirtual
	void onNotificationReceived(NotificationRefreshInfo info) {
		if (notificationTypeSubscription().contains(info.type) && shouldNotificationRefresh(info))
	    load();
	}

	bool hasOption(StatefulOption option) => options.contains(option);

	@override
	Future<void> close() {
		_routeObserver.unsubscribe(this);
		return super.close();
	}

	@override
  void onGoToForeground() {
		if (notificationTypeSubscription().isNotEmpty)
			_notificationService.observeNotifications(this);
		if (!hasOption(StatefulOption.noAutoLoading))
			load();
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
	void didPush() => onGoToForeground();

	@override
	void didPushNext() => onGoToBackground();
}
