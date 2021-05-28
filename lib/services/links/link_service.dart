import 'package:flutter/widgets.dart';
import 'package:fokus/services/app_route_observer.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/settings/password_change/password_change_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/auth/link_payload.dart';
import 'package:fokus/model/ui/auth/password_change_type.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus_auth/fokus_auth.dart';

enum AppState {
	opened, running
}

abstract class LinkService {
	@protected
	final Logger logger = Logger('LinkService');

	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();
  final _routeObserver = GetIt.I<AppRouteObserver>();
	final AuthenticationProvider _authenticationProvider = GetIt.I<AuthenticationProvider>();

  LinkService() {
    initialize();
  }

  @protected
	void initialize();

	void handleLink(Uri? link, AppState appState) async {
		if (link == null)
			return;
		// Wait for the navigator
		await _routeObserver.navigatorInitialized;
		logger.fine('AppLink received $link');
		var navigator = _navigatorKey.currentState;
		if (navigator == null)
			return;
		var payload = LinkPayload.fromLink(link);
		if (!(await _navigateToCaregiverSignInPage(navigator: navigator, payload: payload)))
			return;
		
		if (payload.type == AppLinkType.passwordReset)
			showPasswordChangeDialog(navigator.context, cubit: PasswordChangeCubit(PasswordChangeType.reset, passwordResetCode: payload.oobCode), dismissible: false);
		else {
      if (!await _runGuarded(_authenticationProvider.verifyAccount, payload, navigator.context))
        return;
		  showSuccessSnackbar(navigator.context, 'authentication.accountVerified');
		}
	}
	
	Future<bool> _navigateToCaregiverSignInPage({required NavigatorState navigator, required LinkPayload payload}) async {
		// ignore: close_sinks
		var authBloc = BlocProvider.of<AuthenticationBloc>(navigator.context);
		var userState = authBloc.state;
		// If the app was opened wait for the first auth state to figure out if we need to sign out anyone
		if (userState.status == AuthenticationStatus.initial)
			userState = (await authBloc.stream.firstWhere((element) => element.status != AuthenticationStatus.initial));
		// Bail out early if the code is not valid
		if (payload.type == AppLinkType.passwordReset && !(await _runGuarded(_authenticationProvider.verifyPasswordResetCode, payload, navigator.context)))
			return false;
		// Sign out a user if necessary
		if (userState.signedIn) {
			authBloc.add(AuthenticationSignOutRequested());
			var nextState = (await authBloc.stream.first);
			if (nextState.status != AuthenticationStatus.unauthenticated)
				logger.warning("Current user was not signed out");
		}
		// Redirect to caregiver sign in page
		navigator.pushNamed(AppPage.caregiverSignInPage.name, arguments: payload.email);
		return true;
	}
	
	Future<bool> _runGuarded(Future Function(String) function, LinkPayload payload, BuildContext context) async {
    try {
      await function(payload.oobCode);
    } on EmailCodeFailure catch (e) {
      showFailSnackbar(context, 'authentication.error.emailLink', {
        'TYPE': '${payload.type.index}',
        'ERR': '${e.reason!.index}'
      });
      return false;
    }
    return true;
  }
}
