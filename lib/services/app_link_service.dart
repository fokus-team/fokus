import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:uni_links/uni_links.dart';

class AppLinkService {
	final Logger _logger = Logger('AppLinkService');
	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();

	StreamSubscription _subscription;
	
	AppLinkService() {
		_initialize();
	}

	void _initialize() async {
		try {
			Uri initialUri = await getInitialUri();
			_processAppLink(initialUri);
		} on FormatException catch(e) {
			_logger.warning('Application started with invalid App Link', e);
		}
		_subscription = getUriLinksStream().listen((Uri uri) {
			_processAppLink(uri);
		}, onError: (e) {
			_logger.warning('Application resumed with invalid App Link', e);
		});
	}

	void _processAppLink(Uri link) {
		if (link == null)
			return;
		var context = _navigatorKey.currentState.context;
		var activeUser = BlocProvider.of<AuthenticationBloc>(context).state.user;

	}
}
