import 'dart:convert';

import 'package:fokus/services/app_locales.dart';

abstract class NotificationText {
	String translate();
	Map<String, String> getTranslations();
	Map<String, dynamic> toJson(String name);
}

class ComplexNotificationText implements NotificationText {
	final List<SimpleNotificationText> parts;

  ComplexNotificationText(this.parts);

  @override
  Map<String, String> getTranslations() {
  	if (parts == null || parts.isEmpty)
  		return Map.fromEntries(AppLocalesDelegate.supportedLocales.map((locale) => MapEntry(locale.languageCode, '')));
  	var firstPart = parts.first.getTranslations();
  	return parts.skip(1).fold(firstPart, (translations, part) {
  		part.getTranslations().forEach((key, value) => translations[key] += value);
  		return translations;
	  });
  }

  @override
  String translate() {
	  if (parts == null || parts.isEmpty)
	  	return '';
	  return parts.fold('', (translation, part) => translation += part.translate());
  }

	Map<String, dynamic> toJson(String name) => {};
}

class SimpleNotificationText implements NotificationText {
	final String hardcoded;
	final String key;
	final Map<String, String> arguments;

	const SimpleNotificationText._({this.hardcoded, this.key, this.arguments});

  const SimpleNotificationText.appBased(String key, [Map<String, String> arguments]) : this._(key: key, arguments: arguments);
	const SimpleNotificationText.userBased(String text) : this._(hardcoded: text);

	@override
	String translate() => hardcoded != null ? hardcoded : AppLocales.instance.translate(key, arguments);

	@override
	Map<String, String> getTranslations() {
	  if (key != null)
		  return AppLocales.instance.getTranslations(key, arguments);
		return Map.fromEntries(AppLocalesDelegate.supportedLocales.map((e) => MapEntry(e.languageCode, hardcoded)));
	}
	
	// FCM
	
	SimpleNotificationText.fromJson(String name, Map<dynamic, dynamic> map) :
				this.appBased(map['${name}Key'], map['${name}Args'] != null ? json.decode(map['${name}Args']) : null);

	@override
	Map<String, dynamic> toJson(String name) => {
		'${name}Key': key,
		if (arguments != null)
			'${name}Args': json.encode(arguments)
	};
}
