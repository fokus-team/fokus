import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:fokus/services/exception/no_db_connection.dart';
import 'package:fokus/widgets/dialogs/dialog.dart';
import 'package:fokus/model/button_type.dart';

class CrashHandler {
	GlobalKey<NavigatorState> _navigatorKey;

	CrashHandler.runAppGuarded(Widget app, this._navigatorKey) {
		Crashlytics.instance.enableInDevMode = true;
		FlutterError.onError = Crashlytics.instance.recordFlutterError;
		Isolate.current.addErrorListener(RawReceivePort((pair) async {
			final List<dynamic> errorAndStacktrace = pair;
			await Crashlytics.instance.recordError(
				errorAndStacktrace.first,
				errorAndStacktrace.last,
			);
		}).sendPort);

		runZonedGuarded<Future<void>>(() async {
			runApp(app);
		}, (dynamic error, StackTrace stackTrace) {
			if (_handleInApplication(error, stackTrace))
				return;
			Crashlytics.instance.recordError(error, stackTrace);
			FlutterError.dumpErrorToConsole(FlutterErrorDetails(exception: error, stack: stackTrace));
		});
	}

	bool _handleInApplication(dynamic error, StackTrace stackTrace) {
		if (_navigatorKey?.currentState?.overlay != null) {
			if (error is NoDbConnection) // TODO Handle differently, show info on page / only offline data
				showDialog(
					context: _navigatorKey.currentState.overlay.context,
					builder: (context) => AppDialog(
						titleKey: 'alert.noConnection',
						textKey: 'alert.connectionRetry',
						buttons: [DialogButton(ButtonType.ok, () => Navigator.of(context).pop())],
					),
				);
			return true;
		}
		return false;
	}
}
