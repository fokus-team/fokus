import 'dart:convert';

import 'package:fokus/services/app_locales.dart';

class NotificationText {
	final String hardcoded;
	final String key;
	final Map<String, String> arguments;

	NotificationText._({this.hardcoded, this.key, this.arguments});

  NotificationText.appBased(String key, [Map<String, String> arguments]) : this._(key: key, arguments: arguments);
	NotificationText.userBased(String text) : this._(hardcoded: text);

	String translate() => hardcoded != null ? hardcoded : AppLocales.instance.translate(key, arguments);

	Map<String, String> getTranslations() {
	  if (key != null)
		  return AppLocales.instance.getTranslations(key, arguments);
		return Map.fromEntries(AppLocalesDelegate.supportedLocales.map((e) => MapEntry(e.languageCode, hardcoded)));
	}
	
	// FCM
	
	NotificationText.fromJson(String name, Map<dynamic, dynamic> map) :
				this.appBased(map['${name}Key'], map['${name}Args'] != null ? json.decode(map['${name}Args']) : null);

	Map<String, dynamic> toJson(String name) => {
		'${name}Key': key,
		if (arguments != null)
			'${name}Args': json.encode(arguments)
	};
}
