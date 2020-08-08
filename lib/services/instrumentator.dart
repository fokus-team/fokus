import 'dart:async';
import 'dart:isolate';

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:fokus/widgets/dialogs/dialog.dart';
import 'package:fokus/model/ui/button.dart';

import 'exception/db_exceptions.dart';

class Instrumentator {
	final Logger _logger = Logger('Instrumentator');
	GlobalKey<NavigatorState> _navigatorKey;

	Instrumentator.runAppGuarded(Widget app, this._navigatorKey) {
		_setupLogger();
		_setupCrashlytics();

		runZonedGuarded<Future<void>>(() async {
			runApp(app);
		}, (dynamic error, StackTrace stackTrace) {
			_logger.severe('', error, stackTrace);
			if (_handleError(error, stackTrace))
				return;
			Crashlytics.instance.recordError(error, stackTrace);
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
		Crashlytics.instance.enableInDevMode = true;
		FlutterError.onError = Crashlytics.instance.recordFlutterError;
		Isolate.current.addErrorListener(RawReceivePort((pair) async {
			final List<dynamic> errorAndStacktrace = pair;
			await Crashlytics.instance.recordError(
				errorAndStacktrace.first,
				errorAndStacktrace.last,
			);
		}).sendPort);
	}

	bool _handleError(dynamic error, StackTrace stackTrace) {
		if (_navigatorKey?.currentState?.overlay != null) {
			if (error is NoDbConnection) { // TODO Handle differently, show info on page / only offline data
				showDialog(
					context: _navigatorKey.currentState.overlay.context,
					builder: (context) =>
						AppDialog(
							titleKey: 'alert.noConnection',
							textKey: 'alert.connectionRetry',
							buttons: [UIButton(ButtonType.ok, (_) => Navigator.of(context).pop())],
						),
				);
				return true;
			}
		}
		return false;
	}
}
