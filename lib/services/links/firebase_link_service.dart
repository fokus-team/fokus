import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'link_service.dart';

class FirebaseDynamicLinkService extends LinkService {
  @override
  void initialize() async {
	  FirebaseDynamicLinks.instance.onLink(
			  onSuccess: (PendingDynamicLinkData? dynamicLink) async => handleLink(dynamicLink?.link, AppState.running),
			  onError: (OnLinkErrorException? e) async {
				  logger.severe('Error processing dynamic link', e);
			  }
	  );

	  final data = await FirebaseDynamicLinks.instance.getInitialLink();
	  handleLink(data?.link, AppState.opened);
  }
}
