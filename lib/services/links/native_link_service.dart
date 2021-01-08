import 'package:fokus/services/links/link_service.dart';
import 'package:uni_links/uni_links.dart';

class NativeLinkService extends LinkService {
	@override
	void initialize() async {
		try {
			Uri initialUri = await getInitialUri();
			handleLink(initialUri, AppState.opened);
		} on FormatException catch(e) {
			logger.warning('Application started with invalid App Link', e);
		}
		getUriLinksStream().listen((Uri uri) {
			handleLink(uri, AppState.running);
		}, onError: (e) {
			logger.warning('Application resumed with invalid App Link', e);
		});
	}
}
