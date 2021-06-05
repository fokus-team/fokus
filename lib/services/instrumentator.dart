import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' as Foundation;

import 'package:fokus/model/app_error_type.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/ui/app_page.dart';

import 'analytics_service.dart';
import 'app_route_observer.dart';
import 'exception/db_exceptions.dart';
import 'observers/user/user_observer.dart';

class Instrumentator implements UserObserver {
	final Logger _logger = Logger('Instrumentator');
	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	final _routeObserver = GetIt.I<AppRouteObserver>();

	bool _errorPageOpen = false;
	Set<String> _subLoggers = {'RoundSpot', 'MongoDart'};

	void runAppGuarded(Widget app) {
		Bloc.observer = FokusBlocObserver();
		_setupLogger();
		_setupCrashlytics();

		runZonedGuarded<Future<void>>(() async => runApp(app), (dynamic error, StackTrace stackTrace) async {
			if (await _handleError(error, stackTrace))
				return;
			_logger.severe('', error, stackTrace);
			FirebaseCrashlytics.instance.recordError(error, stackTrace);
		});
	}

	void _setupLogger() {
		Logger.root.level = Foundation.kReleaseMode ? Level.SEVERE : Level.ALL;
		Logger.root.onRecord.listen((record) {
			if (_subLoggers.any((name) => record.loggerName.startsWith(name)))
				return;
			var simpleName = record.loggerName;
			if(simpleName.contains('.'))
				simpleName = simpleName.substring(record.loggerName.lastIndexOf('.') + 1);
			var message = '${record.level.name} [${DateFormat.Hms().format(record.time)}] $simpleName: ${record.message}';
			if (record.level == Level.SEVERE) {
				if (record.error != null)
					message += '\n${record.error.runtimeType} was thrown';
				if (record.stackTrace != null)
					message += '\nStacktrace:\n${record.stackTrace}';
			}
			print(message);
		});
	}

	void _setupCrashlytics() {
		FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
		FlutterError.onError = (FlutterErrorDetails error) async {
			await _routeObserver.navigatorInitialized;
			_navigateToErrorPage(AppErrorType.unknownError);
			FirebaseCrashlytics.instance.recordFlutterError(error);
		};
		Isolate.current.addErrorListener(RawReceivePort((pair) async {
			final List<dynamic> errorAndStacktrace = pair;
			await FirebaseCrashlytics.instance.recordError(
				errorAndStacktrace.first,
				errorAndStacktrace.last,
			);
		}).sendPort);
	}

	Future<bool> _handleError(dynamic error, StackTrace stackTrace) async {
		await _routeObserver.navigatorInitialized;
		if (_navigatorKey.currentState?.context != null) {
			if (error is BlocUnhandledErrorException)
				error = error.error;
			if (error is! SocketException) { // ignore database disconnected socket exception
				var errorType = error is NoDbConnection ? AppErrorType.noConnectionError : AppErrorType.unknownError;
				_navigateToErrorPage(errorType);
			}
			return error is NoDbConnection || error is SocketException ? true : false;
		}
		return false;
	}

	void _navigateToErrorPage(AppErrorType errorType) async {
		if (_errorPageOpen || !Foundation.kReleaseMode || _navigatorKey.currentState == null)
			return;
		_errorPageOpen = true;
	  await Navigator.pushNamed(_navigatorKey.currentState!.context, AppPage.errorPage.name, arguments: errorType);
	  _errorPageOpen = false;
	}

  @override
  void onUserSignIn(User user) {
		if (user.id == null)
			return;
		var id = user.id!.toHexString();
	  FirebaseCrashlytics.instance.setUserIdentifier(id);
	  _analyticsService.setUserId(id);
  }

  @override
  void onUserSignOut(User user) {
	  FirebaseCrashlytics.instance.setUserIdentifier('');
	  _analyticsService.setUserId(null);
  }
}

class FokusBlocObserver extends BlocObserver {
	final Logger _logger = Logger('FokusBlocObserver');

	@override
  void onError(BlocBase cubit, Object error, StackTrace stackTrace) {
		_logger.severe('Cubit ${cubit.runtimeType} exception unhandled', error, stackTrace);
		super.onError(cubit, error, stackTrace);
  }
}
