import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class AppInfoDialog extends StatefulWidget {
	@override
	_AppInfoDialogState createState() => new _AppInfoDialogState();
}

class _AppInfoDialogState extends State<AppInfoDialog> {
	final String _settingsKey = 'page.settings.content.appSettings.appInfo';

	PackageInfo _packageInfo = PackageInfo();

	final String creators = 'Stanisław Góra, Mateusz Janicki,\nMikołaj Mirko, Jan Czubiak';
	final String githubURL = 'https://github.com/fokus-team/fokus';
	final String termsURL = 'https://fokus-team.github.io/terms_of_use.html';
	final String privacyURL = 'https://fokus-team.github.io/privacy_policy.html';

	_openBrowserpage(BuildContext context, String url) async {
		if (await canLaunch(url)) {
			await launch(url);
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
										onTap: () => _openBrowserpage(context, githubURL)
									),
									ListTile(
										title: Text(AppLocales.of(context).translate('$_settingsKey.termsOfUse')),
										trailing: Padding(
											padding: EdgeInsets.only(left: 4.0, top: 2.0),
											child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
										),
										leading: Icon(Icons.description),
										onTap: () => _openBrowserpage(context, termsURL)
									),
									ListTile(
										title: Text(AppLocales.of(context).translate('$_settingsKey.privacyPolicy')),
										trailing: Padding(
											padding: EdgeInsets.only(left: 4.0, top: 2.0),
											child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
										),
										leading: Icon(Icons.lock_clock),
										onTap: () => _openBrowserpage(context, privacyURL)
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
