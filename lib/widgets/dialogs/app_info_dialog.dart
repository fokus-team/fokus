import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoDialog extends StatelessWidget {
	final String _settingsKey = 'page.settings.content';

	final String version = '0.0.1';
	final String creators = 'Stanisław Góra, Mateusz Janicki,\nMikołaj Mirko, Jan Czubiak';
	final String githubURL = 'https://github.com/fokus-team/fokus';
	final String policyURL = 'https://github.com/fokus-team/fokus';

	_openBrowserpage(String url) async {
		if (await canLaunch(url)) {
			await launch(url);
		} else {
			throw 'Could not launch $url';
		}
	}

	@override
	Widget build(BuildContext context) {
		return Dialog(
			insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
			child: Column(
				children: [
					Expanded(
						child: Padding(
							padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
							child: ListView(
								children: [
									Padding(
										padding: EdgeInsets.only(bottom: 2.0),
										child: Center(child: Lottie.asset('assets/animation/sunflower.json', width: 140.0))
									),
									Text(
										AppLocales.of(context).translate('fokus'),
										style: Theme.of(context).textTheme.headline1,
										textAlign: TextAlign.center,
									),
									Text(
										'${AppLocales.of(context).translate('$_settingsKey.appInfoVersion')} $version',
										style: Theme.of(context).textTheme.caption,
										textAlign: TextAlign.center,
									),
									Padding(
										padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
										child: Text(
											AppLocales.of(context).translate('$_settingsKey.appInfoDescription'),
											textAlign: TextAlign.justify,
										)
									),
									Padding(
										padding: EdgeInsets.only(bottom: 20.0),
										child: Text(
											AppLocales.of(context).translate('$_settingsKey.appInfoCreatedBy') + ':\n' + creators,
											style: TextStyle().copyWith(fontStyle: FontStyle.italic),
											textAlign: TextAlign.center,
										)
									),
									ListTile(
										title: Text(AppLocales.of(context).translate('$_settingsKey.goToProjectPage')),
										trailing: Padding(
											padding: EdgeInsets.only(left: 4.0, top: 2.0),
											child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
										),
										leading: Icon(Icons.filter_vintage),
										onTap: () => _openBrowserpage(githubURL)
									),
									ListTile(
										title: Text(AppLocales.of(context).translate('$_settingsKey.showPrivacyPolicy')),
										trailing: Padding(
											padding: EdgeInsets.only(left: 4.0, top: 2.0),
											child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
										),
										leading: Icon(Icons.description),
										onTap: () => _openBrowserpage(policyURL)
									)
								]
							)
						)
					),
					Padding(
						padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
						child: Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								FlatButton(
									textColor: AppColors.caregiverBackgroundColor,
									child: Text(AppLocales.of(context).translate('$_settingsKey.appInfoLicences')),
									onPressed: () => showLicensePage(
										context: context,
										applicationName: AppLocales.of(context).translate('fokus'),
										applicationIcon: Image.asset('assets/image/sunflower_logo.png', height: 64)
									),
								),
								FlatButton(
									textColor: AppColors.caregiverBackgroundColor,
									child: Text(AppLocales.of(context).translate('actions.close')),
									onPressed: () => Navigator.of(context).pop(),
								)
							]
						)
					)
				]
			)
		);
	}
}
