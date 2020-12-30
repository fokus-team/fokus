import 'dart:async';

import 'package:fokus/services/links/link_service.dart';
import 'package:uni_links/uni_links.dart';

class NativeLinkService extends LinkService {
	StreamSubscription _subscription;

	@override
	void initialize() async {
		try {
			Uri initialUri = await getInitialUri();
			handleLink(initialUri);
		} on FormatException catch(e) {
			logger.warning('Application started with invalid App Link', e);
		}
		_subscription = getUriLinksStream().listen((Uri uri) {
			handleLink(uri);
		}, onError: (e) {
			logger.warning('Application resumed with invalid App Link', e);
		});
	}
}
