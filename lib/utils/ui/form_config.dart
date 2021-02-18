import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fokus/services/app_locales.dart';

class AppFormProperties {
	static int textFieldMaxLength = 120;
	static int longTextFieldMaxLength = 1000;
	static int longTextMinLines = 4;
	static int longTextMaxLines = 6;

	static InputDecoration _baseFieldDecoration(IconData icon) {
		return InputDecoration(
			icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(icon)),
			border: OutlineInputBorder()
		);
	}

	static InputDecoration textFieldDecoration(IconData icon) {
		return _baseFieldDecoration(icon).copyWith(
			contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
		);
	}

	static InputDecoration longTextFieldDecoration(IconData icon) {
		return _baseFieldDecoration(icon).copyWith(
			contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
			alignLabelWithHint: true
		);
	}

}

final Email emailBlueprint = Email(
  subject: AppLocales.instance.translate('emailSubject'),
  recipients: ['contact@fokus.link'],
  isHTML: false,
);



