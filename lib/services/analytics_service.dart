import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:fokus_auth/fokus_auth.dart';

class AnalyticsService {
	final FirebaseAnalytics _analytics = FirebaseAnalytics();

	FirebaseAnalyticsObserver get pageObserver => FirebaseAnalyticsObserver(analytics: _analytics);

	void logSignUp(AuthMethod method) => _analytics.logSignUp(signUpMethod: method.name);
	void logSignIn(AuthMethod method) => _analytics.logLogin(loginMethod: method.name);
	void logChildSignUp() => _analytics.logEvent(name: 'child_sign_up');
	void logChildSignIn() => _analytics.logEvent(name: 'child_login');
}
