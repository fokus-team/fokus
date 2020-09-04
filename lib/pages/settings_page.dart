import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_bar_buttons.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:smart_select/smart_select.dart';

class SettingsPage extends StatefulWidget {
	@override
	_SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
	static const String _pageKey = 'page.settings';

	List<String> languages = ['en', 'pl'];
	Map<String, String> counties = {
		'en': 'US',
		'pl': 'PL'
	};
	String pickedLanguage;
	bool notificationSetting;

	@override
  void initState() {
    super.initState();
		// Change with user settings
		notificationSetting = true;
  }

  @override
  Widget build(BuildContext context) {
    pickedLanguage = pickedLanguage ?? AppLocales.of(context).locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocales.of(context).translate('$_pageKey.header.title'))
      ),
			body: Column(
				children: [
					Expanded(
						child: ListView.separated(
							shrinkWrap: true,
							itemCount: _getSettingsFields().length,
							separatorBuilder: (context, index) => Divider(color: Colors.black12, height: 1.0),
							itemBuilder: (context, index) => _getSettingsFields()[index]
						)
					)
				]
			)
		);
  }

	List<Widget> _getSettingsFields() {
		return [
			// TODO profile edit (for caregiver name/password) 
			// ListTile(
			// 	title: Text(AppLocales.of(context).translate('$_pageKey.content.myProfileTitle')),
			// 	subtitle: Text(AppLocales.of(context).translate('$_pageKey.content.myProfileHint')),
			// 	trailing: Padding(
			// 		padding: EdgeInsets.only(left: 4.0, top: 2.0),
			// 		child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
			// 	),
			// 	leading: Icon(Icons.person),
			// 	onTap: () => {}
			// ),
			SmartSelect.single(
				value: pickedLanguage,
				title: AppLocales.of(context).translate('$_pageKey.content.changeAppLanguage'),
				modalType: SmartSelectModalType.bottomSheet,
				options: [
					for(String lang in languages)
						SmartSelectOption(
							title: AppLocales.of(context).translate('$_pageKey.content.languages.$lang'),
							value: lang
						)
				],
				modalConfig: SmartSelectModalConfig(
					trailing: ButtonSheetBarButtons(
						buttons: [
							UIButton('actions.confirm', () => { Navigator.pop(context) }, Colors.green, Icons.done)
						],
					)
				),
				leading: Icon(Icons.language),
				onChange: (String val) {
					setState(() => pickedLanguage = val);
					// Change app language
				}
			),
			SwitchListTile(
				value: notificationSetting,
				title: Text(AppLocales.of(context).translate('$_pageKey.content.manageAppNotifications')),
				secondary: Icon(Icons.notifications),
				onChanged: (bool val) => setState(() => notificationSetting = val)
			),
			ListTile(
				title: Text(AppLocales.of(context).translate('$_pageKey.content.showAppInfo')),
				trailing: Padding(
					padding: EdgeInsets.only(left: 4.0, top: 2.0),
					child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
				),
				leading: Icon(Icons.info),
				onTap: () => showAppInfoDialog(context)
			)
		];
	}

}
