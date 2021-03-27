// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

enum ExternalURL { webpage, github, termsOfUse, privacyPolicy }

extension ExternalURLLink on ExternalURL {
  String get url => const {
	  ExternalURL.webpage: 'https://fokus.link/',
	  ExternalURL.github: 'https://github.com/fokus-team/fokus',
	  ExternalURL.termsOfUse: 'https://fokus.link/terms_of_use.html',
	  ExternalURL.privacyPolicy: 'https://fokus.link/privacy_policy.html',
  }[this];
	
	void openBrowserPage(BuildContext context) async {
		if (await canLaunch(this.url)) {
			await launch(this.url);
		} else {
			showBasicDialog(
				context,
				GeneralDialog.discard(
					title: AppLocales.of(context).translate('alert.errorOccurred'),
					content: AppLocales.of(context).translate('alert.noConnection')
				)
			);
		}
	}
}
