import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/award/ui_badge.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/form_config.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/forms/iconpicker_field.dart';
import 'package:smart_select/smart_select.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class CaregiverBadgeFormPage extends StatefulWidget {
	@override
	_CaregiverBadgeFormPageState createState() => new _CaregiverBadgeFormPageState();
}

class _CaregiverBadgeFormPageState extends State<CaregiverBadgeFormPage> {
	static const String _pageKey = 'page.caregiverSection.badgeForm';
	AppFormType formType = AppFormType.create; // only create for now
	GlobalKey<FormState> badgeFormKey;
	bool isDataChanged = false;

	UIBadge badge;

	TextEditingController _titleController = TextEditingController();
	TextEditingController _descriptionController = TextEditingController();

	@override
  void initState() {
		badgeFormKey = GlobalKey<FormState>();
		badge = UIBadge();
		_titleController.text = '';
		_descriptionController.text = '';
    super.initState();
  }
	
	@override
  void dispose() {
		_titleController.dispose();
		_descriptionController.dispose();
		super.dispose();
	}

  @override
  Widget build(BuildContext context) {
		return WillPopScope(
			onWillPop: () => showExitFormDialog(context, true, isDataChanged),
			child: Scaffold(
				appBar: AppBar(
					backgroundColor: AppColors.formColor,
					title: Text(AppLocales.of(context).translate(
						formType == AppFormType.create ? '$_pageKey.addBadgeTitle' : '$_pageKey.editBadgeTitle'
					)),
					actions: <Widget>[
						HelpIconButton(helpPage: 'badge_creation')
					]
				),
				body: Stack(
					children: [
						Positioned.fill(
							bottom: AppBoxProperties.standardBottomNavHeight,
							child: Form(
								key: badgeFormKey,
								child: Material(
									child: buildFormFields(context)
								)
							)
						),
						Positioned.fill(
							top: null,
							child: buildBottomNavigation(context)
						)
					]
				)
			)
		);
	}

	void saveBadge(BuildContext context) {
		if(badgeFormKey.currentState.validate()) {
			// TODO adding/saving logic
			Navigator.of(context).pop();
		}
	}

	void removeBadge(BuildContext context) {
		// TODO remove logic
	}

	Widget buildBottomNavigation(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
			decoration: AppBoxProperties.elevatedContainer,
			height: AppBoxProperties.standardBottomNavHeight,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.end,
				children: <Widget>[
					(formType == AppFormType.edit) ?
						FlatButton(
							onPressed: () => removeBadge(context),
							child: Text(
								AppLocales.of(context).translate('$_pageKey.removeBadgeButton'),
								style: Theme.of(context).textTheme.button.copyWith(color: Colors.red)
							)
						) : SizedBox.shrink(),
					FlatButton(
						onPressed: () => saveBadge(context),
						child: Text(
							AppLocales.of(context).translate(formType == AppFormType.create ? '$_pageKey.addBadgeButton' : '$_pageKey.saveBadgeButton' ),
							style: Theme.of(context).textTheme.button.copyWith(color: AppColors.mainBackgroundColor)
						)
					)
				]
			)
		);
	}

	Widget buildFormFields(BuildContext context) {
		return ListView(
			shrinkWrap: true,
			children: <Widget>[
				buildNameField(context),
				buildDescriptionField(context),
				buildLevelField(context),
				buildIconField(context)
			]
		);
	}

	Widget buildNameField(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 20.0, bottom: 6.0, left: 20.0, right: 20.0),
			child: TextFormField(
				controller: _titleController,
				decoration: AppFormProperties.textFieldDecoration(Icons.edit).copyWith(
					labelText: AppLocales.of(context).translate('$_pageKey.fields.badgeName.label')
				),
				maxLength: AppFormProperties.textFieldMaxLength,
				textCapitalization: TextCapitalization.sentences,
				validator: (value) {
					return value.trim().isEmpty ? AppLocales.of(context).translate('$_pageKey.fields.badgeName.emptyError') : null;
				},
				onChanged: (val) => setState(() {
					badge.name = val;
					isDataChanged = true;
				})
			)
		);
	}
	
	Widget buildDescriptionField(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 5.0, bottom: 6.0, left: 20.0, right: 20.0),
			child: TextFormField(
				controller: _descriptionController,
				decoration: AppFormProperties.longTextFieldDecoration(Icons.description).copyWith(
					labelText: AppLocales.of(context).translate('$_pageKey.fields.badgeDescription.label')
				),
				maxLength: AppFormProperties.longTextFieldMaxLength,
				minLines: AppFormProperties.longTextMinLines,
				maxLines: AppFormProperties.longTextMaxLines,
				textCapitalization: TextCapitalization.sentences,
				onChanged: (val) => setState(() {
					badge.description = val;
					isDataChanged = true;
				})
			)
		);
	}

	Widget buildLevelField(BuildContext context) {
		return SmartSelect<UIBadgeMaxLevel>.single(
			title: AppLocales.of(context).translate('$_pageKey.fields.badgeLevel.label'),
			value: badge.maxLevel,
			options: [
				for(UIBadgeMaxLevel element in UIBadgeMaxLevel.values)
					SmartSelectOption(
						title: AppLocales.of(context).translate('$_pageKey.fields.badgeLevel.options.${element.toString().split('.').last}'),
						value: element
					)
			],
			isTwoLine: true,
			modalType: SmartSelectModalType.bottomSheet,
			leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.layers)),
			onChange: (val) => setState(() {
				badge.maxLevel = val;
				isDataChanged = true;
			})
		);
	}
	
	Widget buildIconField(BuildContext context) {
		return IconPickerField.badge(
			title: AppLocales.of(context).translate('$_pageKey.fields.badgeIcon.label'),
			groupTextKey: '$_pageKey.fields.badgeIcon.groups',
			value: badge.icon,
			callback: (val) => setState(() {
				FocusManager.instance.primaryFocus.unfocus();
				badge.icon = val;
			})
		);
	}

}
