import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fokus/utils/ui/form_config.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_confirm_button.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:smart_select/smart_select.dart';

import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/logic/common/settings/locale_cubit.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';

class SettingsPage extends StatefulWidget {
	@override
	_SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
	static const String _pageKey = 'page.settings.content';

	List<String> languages = [LocaleCubit.defaultLanguageKey, ...AppLocalesDelegate.supportedLocales.map((locale) => '$locale')];
	String _pickedLanguage;

  @override
  Widget build(BuildContext context) {
	  // ignore: close_sinks
    var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    var isCurrentUserCaregiver = authenticationBloc.state.user?.role == UserRole.caregiver;

		// Loading current locale (don't work with "default" option)
    _pickedLanguage = _pickedLanguage ?? AppLocales.of(context).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocales.of(context).translate('page.settings.header.title'))
      ),
			body: Column(
				children: [
					Expanded(
						child: ListView(
							shrinkWrap: true,
							children: [
								if(isCurrentUserCaregiver)
									..._buildSettingsList(
										AppLocales.of(context).translate('$_pageKey.profile.header'),
										_getProfileFields()
									),
								..._buildSettingsList(
										AppLocales.of(context).translate('$_pageKey.appSettings.header'),
									_getSettingsFields(isCurrentUserCaregiver)
								)
							]
						)
					)
				]
			)
		);
  }

	List<Widget> _buildSettingsList(String title, List<Widget> fields) {
		return [
			Padding(
				padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding, vertical: 20.0).copyWith(bottom: 6.0),
				child: Text(
					title,
					style: TextStyle(fontWeight: FontWeight.bold),
					textAlign: TextAlign.left,
				)
			),
			ListView.separated(
				shrinkWrap: true,
				physics: NeverScrollableScrollPhysics(),
				itemCount: fields.length,
				separatorBuilder: (context, index) => Divider(color: Colors.black12, height: 1.0),
				itemBuilder: (context, index) => fields[index]
			)
		];
	}

	Widget _buildBasicListTile({String title, String subtitle, IconData icon, Color color, Function onTap}) {
		return ListTile(
			title: Text(title, style: TextStyle(color: color ?? Colors.black)),
			subtitle: subtitle != null ? Text(subtitle) : null,
			trailing: Padding(
				padding: EdgeInsets.only(left: 4.0, top: 2.0),
				child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
			),
			leading: Padding(
				padding: EdgeInsets.only(left: 8.0),
				child: Icon(icon, color: color ?? Colors.grey[600])
			),
			onTap: onTap
		);
	}

	List<Widget> _getProfileFields() {
  	var user = BlocProvider.of<AuthenticationBloc>(context).state.user as UICaregiver;
		return [
			if (user.authMethod == AuthMethod.email)
				...[
					_buildBasicListTile(
						title: AppLocales.of(context).translate('$_pageKey.profile.editNameLabel'),
						icon: Icons.edit,
						onTap: () => showNameEditDialog(context, user)
					),
					_buildBasicListTile(
						title: AppLocales.of(context).translate('$_pageKey.profile.changePasswordLabel'),
						icon: Icons.lock,
						onTap: () => showPasswordChangeDialog(context)
					),
				],
			_buildBasicListTile(
				title: AppLocales.of(context).translate('$_pageKey.profile.deleteAccountLabel'),
				subtitle: AppLocales.of(context).translate('$_pageKey.profile.deleteAccountHint'),
				icon: Icons.delete,
				color: Colors.red,
				onTap: () => showAccountDeleteDialog(context, user)
			)
		];
	}

	void _setLanguage(String langKey) {
		if (langKey == LocaleCubit.defaultLanguageKey)
			BlocProvider.of<LocaleCubit>(context).setLocale(setDefault: true);
		else
			BlocProvider.of<LocaleCubit>(context).setLocale(locale: AppLocalesDelegate.supportedLocales.firstWhere((locale) => '$locale' == langKey));
	}

	List<Widget> _getSettingsFields(bool isCurrentUserCaregiver) {
		return [
			BlocBuilder<LocaleCubit, LocaleState>(
				builder: (context, state) {
					return SmartSelect.single(
						value: BlocProvider.of<LocaleCubit>(context).state.languageKey,
						title: AppLocales.of(context).translate('$_pageKey.appSettings.changeLanguageLabel'),
						modalType: SmartSelectModalType.bottomSheet,
						modalConfig: SmartSelectModalConfig(
							useConfirmation: true,
							confirmationBuilder: (context, callback) => ButtonSheetConfirmButton(callback: () => callback)
						),
						options: [
							for(String lang in languages)
								SmartSelectOption(
									title: AppLocales.of(context).translate('$_pageKey.appSettings.languages.$lang'),
									value: lang
								)
						],
						leading: Padding(
							padding: EdgeInsets.only(left: 8.0),
							child: Icon(Icons.language)
						),
						onChange: (langKey) => _setLanguage(langKey),
					);
				}
			),
			isCurrentUserCaregiver ?
			_buildBasicListTile(
					title: AppLocales.of(context).translate('actions.contactUs'),
					subtitle: AppLocales.of(context).translate('$_pageKey.appSettings.contactUsHint'),
					icon: Icons.contact_mail,
					onTap: () async => await FlutterEmailSender.send(emailBlueprint)
			) : SizedBox.shrink(),
			_buildBasicListTile(
				title: AppLocales.of(context).translate('$_pageKey.appSettings.showAppInfoLabel'),
				icon: Icons.info,
				onTap: () => showAppInfoDialog(context)
			)
		];
	}

}
