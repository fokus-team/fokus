import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fokus/model/ui/award/ui_badge.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/forms/iconpicker_field.dart';
import 'package:fokus/widgets/forms/pointpicker_field.dart';
import 'package:smart_select/smart_select.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class CaregiverBadgeFormPage extends StatefulWidget {
	@override
	_CaregiverBadgeFormPageState createState() => new _CaregiverBadgeFormPageState();
}

class _CaregiverBadgeFormPageState extends State<CaregiverBadgeFormPage> {
	static const String _pageKey = 'page.caregiverSection.badgeForm';
	double bottomBarHeight = 60.0;
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
			onWillPop: () => exitForm(context, true),
			child: Scaffold(
				appBar: AppBar(
					backgroundColor: AppColors.formColor,
					title: Text(AppLocales.of(context).translate('$_pageKey.addBadgeTitle')),
					actions: <Widget>[
						HelpIconButton(helpPage: 'badge_creation')
					]
				),
				body: Stack(
					children: [
						Positioned.fill(
							bottom: bottomBarHeight,
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
			Navigator.of(context).pop();
		}
	}

	Future<bool> exitForm(BuildContext context, bool isSystemPop) {
		if (!isDataChanged) {
			Navigator.pop(context, true);
			return Future.value(false);
		} else {
			FocusManager.instance.primaryFocus.unfocus();
			return showDialog<bool>(
				context: context,
				builder: (c) => AlertDialog(
					title: Text(AppLocales.of(context).translate('alert.unsavedProgressTitle')),
					content: Text(AppLocales.of(context).translate('alert.unsavedProgressMessage')),
					actions: [
						FlatButton(
							child: Text(AppLocales.of(context).translate('actions.cancel')),
							onPressed: () => Navigator.pop(c, false),
						),
						FlatButton(
							textColor: Colors.red,
							child: Text(AppLocales.of(context).translate('actions.exit')),
							onPressed: () {
								if(isSystemPop)
									Navigator.pop(c, true);
								else {
									Navigator.of(context).pop();
									Navigator.of(context).pop();
								}
							}
						)
					]
				)
			);
		}
	}

	Widget buildBottomNavigation(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
			decoration: AppBoxProperties.elevatedContainer,
			height: bottomBarHeight,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.end,
				children: <Widget>[
					SizedBox.shrink(),
					FlatButton(
						onPressed: () => saveBadge(context),
						child: Text(
							AppLocales.of(context).translate('$_pageKey.saveBadgeButton'),
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
				decoration: InputDecoration(
					icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.edit)),
					contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
					border: OutlineInputBorder(),
					labelText: AppLocales.of(context).translate('$_pageKey.fields.badgeName.label')
				),
				maxLength: 120,
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
				decoration: InputDecoration(
					icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.description)),
					contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
					border: OutlineInputBorder(),
					labelText: AppLocales.of(context).translate('$_pageKey.fields.badgeDescription.label'),
					alignLabelWithHint: true
				),
				maxLength: 1000,
				maxLines: 6,
				minLines: 4,
				textCapitalization: TextCapitalization.sentences,
				onChanged: (val) => setState(() {
					badge.description = val;
					isDataChanged = true;
				})
			)
		);
	}

	Widget buildLevelField(BuildContext context) {
		return SmartSelect<UIBadgeLevel>.single(
			title: AppLocales.of(context).translate('$_pageKey.fields.badgeLevel.label'),
			value: badge.level,
			options: [
				for(UIBadgeLevel element in UIBadgeLevel.values)
					SmartSelectOption(
						title: AppLocales.of(context).translate('$_pageKey.fields.badgeLevel.options.${element.toString().split('.').last}'),
						value: element
					)
			],
			isTwoLine: true,
			modalType: SmartSelectModalType.bottomSheet,
			leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.layers)),
			onChange: (val) => setState(() {
				badge.level = val;
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
