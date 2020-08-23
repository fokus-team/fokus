import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/award/ui_award.dart';
import 'package:fokus/model/ui/award/ui_points.dart';
import 'package:fokus/model/ui/ui_currency.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/form_config.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/forms/iconpicker_field.dart';
import 'package:fokus/widgets/forms/pointpicker_field.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class CaregiverAwardFormPage extends StatefulWidget {
	@override
	_CaregiverAwardFormPageState createState() => new _CaregiverAwardFormPageState();
}

class _CaregiverAwardFormPageState extends State<CaregiverAwardFormPage> {
	static const String _pageKey = 'page.caregiverSection.awardForm';
	AppFormType formType = AppFormType.create; // only create for now
	GlobalKey<FormState> awardFormKey;
	bool isDataChanged = false;

	UIAward award;

	List<UICurrency> currencies = [
		UICurrency(type: CurrencyType.diamond, title: "Punkty"),
		UICurrency(type: CurrencyType.ruby, title: "Klejnoty"),
		UICurrency(type: CurrencyType.amethyst, title: "Super punkty")
	];

	TextEditingController _titleController = TextEditingController();
	TextEditingController _limitController = TextEditingController();
	TextEditingController _pointsController = TextEditingController();

	@override
  void initState() {
		awardFormKey = GlobalKey<FormState>();
		award = UIAward();
		award.points = UIPoints();
		award.points.currency = currencies[0];
		_titleController.text = '';
		_limitController.text = '';
		_pointsController.text = '';
    super.initState();
  }
	
	@override
  void dispose() {
		_titleController.dispose();
		_limitController.dispose();
		_pointsController.dispose();
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
						formType == AppFormType.create ? '$_pageKey.addAwardTitle' : '$_pageKey.editAwardTitle'
					)),
					actions: <Widget>[
						HelpIconButton(helpPage: 'award_creation')
					]
				),
				body: Stack(
					children: [
						Positioned.fill(
							bottom: AppBoxProperties.standardBottomNavHeight,
							child: Form(
								key: awardFormKey,
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

	void saveAward(BuildContext context) {
		if(awardFormKey.currentState.validate()) {
			// TODO adding/saving logic
			Navigator.of(context).pop();
		}
	}

	void removeAward(BuildContext context) {
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
							onPressed: () => removeAward(context),
							child: Text(
								AppLocales.of(context).translate('$_pageKey.removeAwardButton'),
								style: Theme.of(context).textTheme.button.copyWith(color: Colors.red)
							)
						) : SizedBox.shrink(),
					FlatButton(
						onPressed: () => saveAward(context),
						child: Text(
							AppLocales.of(context).translate(formType == AppFormType.create ? '$_pageKey.addAwardButton' : '$_pageKey.saveAwardButton' ),
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
				buildLimitField(context),
				buildPointsFields(context),
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
					labelText: AppLocales.of(context).translate('$_pageKey.fields.awardName.label')
				),
				maxLength: AppFormProperties.textFieldMaxLength,
				textCapitalization: TextCapitalization.sentences,
				validator: (value) {
					return value.trim().isEmpty ? AppLocales.of(context).translate('$_pageKey.fields.awardName.emptyError') : null;
				},
				onChanged: (val) => setState(() {
					award.name = val;
					isDataChanged = true;
				})
			)
		);
	}

	Widget buildLimitField(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 5.0, bottom: 16.0, left: 20.0, right: 20.0),
			child: TextFormField(
				controller: _limitController,
				decoration: AppFormProperties.textFieldDecoration(Icons.block).copyWith(
					labelText: AppLocales.of(context).translate('$_pageKey.fields.awardLimit.label'),
					hintText: '0',
					helperText: AppLocales.of(context).translate('$_pageKey.fields.awardLimit.hint'),
					suffixIcon: IconButton(
						onPressed: () {
							FocusScope.of(context).requestFocus(FocusNode());
							_limitController.clear();
						},
						icon: Icon(Icons.clear)
					)
				),
				keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
				inputFormatters: <TextInputFormatter>[
						WhitelistingTextInputFormatter.digitsOnly,
						LengthLimitingTextInputFormatter(9),
				],
				onChanged: (val) => setState(() {
					award.limit = int.tryParse(val);
					isDataChanged = true;
				})
			)
		);
	}
	
	Widget buildPointsFields(BuildContext context) {
		return PointPickerField(
			controller: _pointsController,
			pickedCurrency: award.points.currency,
			currencies: currencies,
			loading: false,
			minPoints: 1,
			canBeEmpty: false,
			labelValueText: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.valueLabel'),
			helperValueText: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.hint'),
			labelCurrencyText: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.currencyLabel'),
			pointValueSetter: (val) {
				setState(() {
					isDataChanged = award.points.value != ((val != null) ? int.tryParse(val) : null);
					award.points.value = (val != null) ? int.tryParse(val) : null;
				});
			},
			pointCurrencySetter: (val) {
				setState(() {
					isDataChanged = award.points.currency != val;
					award.points.currency = val;
				});
			},
		);
	}

	Widget buildIconField(BuildContext context) {
		return IconPickerField.award(
			title: AppLocales.of(context).translate('$_pageKey.fields.awardIcon.label'),
			groupTextKey: '$_pageKey.fields.awardIcon.groups',
			value: award.icon,
			callback: (val) => setState(() {
				FocusManager.instance.primaryFocus.unfocus();
				award.icon = val;
			})
		);
	}

}
