import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/settings/password_change/password_change_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/auth/app_link_payload.dart';
import 'package:fokus/model/ui/auth/password_change_type.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus_auth/fokus_auth.dart';
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

	void _processAppLink(Uri link) async {
		if (link == null)
			return;
		_logger.fine('AppLink recieved $link');
		var navigator = _navigatorKey.currentState;
		if (navigator == null)
			return;
		// ignore: close_sinks
		var authBloc = BlocProvider.of<AuthenticationBloc>(navigator.context);
		if (authBloc.state.status == AuthenticationStatus.authenticated) {
			authBloc.add(AuthenticationSignOutRequested());
			var nextState = (await authBloc.first);
			if (nextState.status != AuthenticationStatus.unauthenticated)
				_logger.warning("Current user was not signed out");
		}
		var payload = AppLinkPayload.fromLink(link);
		navigator.pushNamed(AppPage.caregiverSignInPage.name, arguments: payload.email);
		if (payload.type == AppLinkType.passwordReset)
			showPasswordChangeDialog(navigator.context, cubit: PasswordChangeCubit(PasswordChangeType.reset), dismissible: false);
	}
}
