import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/settings/password_change/password_change_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/auth/app_link_payload.dart';
import 'package:fokus/model/ui/auth/password_change_type.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus_auth/fokus_auth.dart';

abstract class LinkService {
	@protected
	final Logger logger = Logger('LinkService');

	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();
	final AuthenticationProvider _authenticationProvider = GetIt.I<AuthenticationProvider>();

	LinkService() {
		initialize();
	}

	@protected
	void initialize();

	void handleLink(Uri link) async {
		if (link == null)
			return;
		logger.fine('AppLink received $link');
		var navigator = _navigatorKey.currentState;
		if (navigator == null)
			return;
		var payload = AppLinkPayload.fromLink(link);
		if (payload.type == AppLinkType.passwordReset && !await _authenticationProvider.verifyPasswordResetCode(payload.oobCode)){
			showFailSnackbar(navigator.context, 'authentication.error.passwordResetCodeInvalid');
			return;
		}
		// ignore: close_sinks
		var authBloc = BlocProvider.of<AuthenticationBloc>(navigator.context);
		if (authBloc.state.status == AuthenticationStatus.authenticated) {
			authBloc.add(AuthenticationSignOutRequested());
			var nextState = (await authBloc.first);
			if (nextState.status != AuthenticationStatus.unauthenticated)
				logger.warning("Current user was not signed out");
		}
		navigator.pushNamed(AppPage.caregiverSignInPage.name, arguments: payload.email);
		if (payload.type == AppLinkType.passwordReset) {
			showPasswordChangeDialog(navigator.context, cubit: PasswordChangeCubit(PasswordChangeType.reset, passwordResetCode: payload.oobCode), dismissible: false);
		}
	}
}
