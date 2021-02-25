import 'package:flutter/widgets.dart';
import 'package:fokus/model/ui/app_page.dart';

Future navigateChecked(BuildContext context, AppPage page, {Object arguments}) {
	if (getCurrentPage(context) != page.name)
		return Navigator.pushNamed(context, page.name, arguments: arguments);
	return Future.value();
}

String getCurrentPage(BuildContext context) {
	String name;
	Navigator.popUntil(context, (route) {
	  name = route.settings.name;
	  return true;
	});
	return name;
}
