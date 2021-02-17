import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'analytics_service.dart';
import 'exception/db_exceptions.dart';
import 'observers/active_user_observer.dart';

class Instrumentator implements ActiveUserObserver {
	final Logger _logger = Logger('Instrumentator');
	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();

	void runAppGuarded(Widget app) {
		Bloc.observer = FokusBlocObserver();
		_setupLogger();
		_setupCrashlytics();

		runZonedGuarded<Future<void>>(() async {
			runApp(app);
		}, (dynamic error, StackTrace stackTrace) {
			if (_handleError(error, stackTrace))
				return;
			_logger.severe('', error, stackTrace);
			FirebaseCrashlytics.instance.recordError(error, stackTrace);
		});
	}

	void _setupLogger() {
		Logger.root.level = Level.ALL;
		Logger.root.onRecord.listen((record) {
			if (record.loggerName.startsWith('MongoDart'))
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
		FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
		Isolate.current.addErrorListener(RawReceivePort((pair) async {
			final List<dynamic> errorAndStacktrace = pair;
			await FirebaseCrashlytics.instance.recordError(
				errorAndStacktrace.first,
				errorAndStacktrace.last,
			);
		}).sendPort);
	}

	bool _handleError(dynamic error, StackTrace stackTrace) {
		if (_navigatorKey?.currentState?.overlay != null) {
			if (error is CubitUnhandledErrorException)
				error = error.error;
			var title = error is NoDbConnection ? 'noConnection' : 'errorOccurred';
			var content = error is NoDbConnection ? 'connectionRetry' : 'errorDescription';
			if (error is! SocketException) // ignore database disconnected socket exception
				showBasicDialog(
					_navigatorKey.currentState.overlay.context,
					GeneralDialog.discard(
						title: AppLocales.instance.translate('alert.$title'),
						content: AppLocales.instance.translate('alert.$content')
					)
				);
			return error is NoDbConnection || error is SocketException ? true : false;
		}
		return false;
	}

  @override
  void onUserSignIn(User user) {
		var id = user.id.toHexString();
	  FirebaseCrashlytics.instance.setUserIdentifier(id);
	  _analyticsService.setUserId(id);
  }

  @override
  void onUserSignOut(User user) {
	  FirebaseCrashlytics.instance.setUserIdentifier('');
	  _analyticsService.setUserId('');
  }
}

class FokusBlocObserver extends BlocObserver {
	final Logger _logger = Logger('FokusBlocObserver');

	@override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
		_logger.severe('Cubit ${cubit.runtimeType} exception unhandled', error, stackTrace);
		super.onError(cubit, error, stackTrace);
  }
}
