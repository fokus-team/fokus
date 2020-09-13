import 'dart:convert';

class LocalizedText {
	final String key;
	final Map<String, String> arguments;

	LocalizedText(this.key, [this.arguments]);
	LocalizedText.fromJson(String name, Map<dynamic, dynamic> map) :
				this(map['${name}Key'], map['${name}Args'] != null ? json.decode(map['${name}Args']) : null);

	Map<String, dynamic> toJson(String name) => {
		'${name}Key': key,
		if (arguments != null)
			'${name}Args': json.encode(arguments)
	};
}
