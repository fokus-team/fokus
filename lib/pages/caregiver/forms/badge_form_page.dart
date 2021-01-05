import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/caregiver/badge_form/badge_form_cubit.dart';
import 'package:fokus/model/ui/form/badge_form_model.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/form_config.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/forms/iconpicker_field.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';

class CaregiverBadgeFormPage extends StatefulWidget {
	@override
	_CaregiverBadgeFormPageState createState() => new _CaregiverBadgeFormPageState();
}

class _CaregiverBadgeFormPageState extends State<CaregiverBadgeFormPage> {
	static const String _pageKey = 'page.caregiverSection.badgeForm';
	GlobalKey<FormState> badgeFormKey;
	bool isDataChanged = false;

	BadgeFormModel badge = BadgeFormModel();

	TextEditingController _titleController = TextEditingController();
	TextEditingController _descriptionController = TextEditingController();

	@override
  void initState() {
		badgeFormKey = GlobalKey<FormState>();
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
		return BlocConsumer<BadgeFormCubit, BadgeFormState>(
			listener: (context, state) {
				if (state is BadgeFormSubmissionSuccess) {
					Navigator.of(context).pop();
					showSuccessSnackbar(context, 'page.caregiverSection.awards.content.badgeAddedText');
				}
			},
	    builder: (context, state) {
				return WillPopScope(
					onWillPop: () => showExitFormDialog(context, true, isDataChanged),
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
		);
	}

	void saveBadge(BuildContext context) {
		if(badgeFormKey.currentState.validate()) {
			BlocProvider.of<BadgeFormCubit>(context).submitBadgeForm(badge);
		}
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
					SizedBox.shrink(),
					FlatButton(
						onPressed: () => saveBadge(context),
						child: Text(
							AppLocales.of(context).translate('$_pageKey.addBadgeButton'),
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
			padding: EdgeInsets.only(top: 5.0, bottom: 0, left: 20.0, right: 20.0),
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
	
	Widget buildIconField(BuildContext context) {
		return IconPickerField.badge(
			title: AppLocales.of(context).translate('$_pageKey.fields.badgeIcon.label'),
			groupTextKey: '$_pageKey.fields.badgeIcon.groups',
			value: badge.icon,
			callback: (val) => setState(() {
				FocusManager.instance.primaryFocus.unfocus();
				badge.icon = val;
				isDataChanged = true;
			})
		);
	}

}
