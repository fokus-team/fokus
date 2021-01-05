import 'package:fokus_auth/fokus_auth.dart';

class AppLinkPayload {
	final String email;
	final AppLinkType type;
	final String oobCode;

  AppLinkPayload._({this.email, this.type, this.oobCode});
  AppLinkPayload.fromLink(Uri link) : this._(
	  email: Uri.parse(Uri.decodeFull(link.queryParameters['continueUrl'])).queryParameters['email'],
	  type: AppLinkType.values.firstWhere((element) => element.key == link.queryParameters['mode'], orElse: () => null),
    oobCode: link.queryParameters['oobCode']
  );
}
