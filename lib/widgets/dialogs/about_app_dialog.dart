import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info/package_info.dart';
import 'package:fokus/model/ui/external_url.dart';

class AboutAppDialog extends StatefulWidget {
	@override
	_AboutAppDialogState createState() => new _AboutAppDialogState();
}

class _AboutAppDialogState extends State<AboutAppDialog> {
	final String _settingsKey = 'page.settings.content.appInfo.about';

	PackageInfo _packageInfo;
	final String creators = 'Stanisław Góra,\nMateusz Janicki,\nMikołaj Mirko';

	@override
	void initState() {
		super.initState();
		_initPackageInfo();
	}

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
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
										_packageInfo.appName ?? AppLocales.of(context).translate('fokus'),
										style: Theme.of(context).textTheme.headline1,
										textAlign: TextAlign.center,
									),
									Text(
										'${AppLocales.of(context).translate('$_settingsKey.version')} ${_packageInfo.version ?? ''}',
										style: Theme.of(context).textTheme.caption,
										textAlign: TextAlign.center,
									),
									Padding(
										padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
										child: Text(
											AppLocales.of(context).translate('$_settingsKey.description'),
											textAlign: TextAlign.justify,
										)
									),
									Padding(
										padding: EdgeInsets.only(bottom: 20.0),
										child: Text(
											AppLocales.of(context).translate('$_settingsKey.creators') + ':\n' + creators,
											style: TextStyle().copyWith(fontStyle: FontStyle.italic),
											textAlign: TextAlign.center,
										)
									),
									ListTile(
										title: Text(AppLocales.of(context).translate('$_settingsKey.projectPage')),
										trailing: Padding(
											padding: EdgeInsets.only(left: 4.0, top: 2.0),
											child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
										),
										leading: Icon(Icons.filter_vintage),
										onTap: () => ExternalURL.webpage.openBrowserPage(context)
									),
									ListTile(
										title: Text(AppLocales.of(context).translate('$_settingsKey.termsOfUse')),
										trailing: Padding(
											padding: EdgeInsets.only(left: 4.0, top: 2.0),
											child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
										),
										leading: Icon(Icons.description),
										onTap: () => ExternalURL.termsOfUse.openBrowserPage(context)
									),
									ListTile(
										title: Text(AppLocales.of(context).translate('$_settingsKey.privacyPolicy')),
										trailing: Padding(
											padding: EdgeInsets.only(left: 4.0, top: 2.0),
											child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
										),
										leading: Icon(Icons.lock_clock),
										onTap: () => ExternalURL.privacyPolicy.openBrowserPage(context)
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
									child: Text(AppLocales.of(context).translate('$_settingsKey.licences')),
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
