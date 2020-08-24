import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/gamification/ui_award.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
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
	double bottomBarHeight = 60.0;
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
		award = UIAward(points: UIPoints(type: currencies[0].type, title: currencies[0].title));
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
			onWillPop: () => exitForm(context, true),
			child: Scaffold(
				appBar: AppBar(
					backgroundColor: AppColors.formColor,
					title: Text(AppLocales.of(context).translate('$_pageKey.addAwardTitle')),
					actions: <Widget>[
						HelpIconButton(helpPage: 'award_creation')
					]
				),
				body: Stack(
					children: [
						Positioned.fill(
							bottom: bottomBarHeight,
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
						onPressed: () => saveAward(context),
						child: Text(
							AppLocales.of(context).translate('$_pageKey.saveAwardButton'),
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
				decoration: InputDecoration(
					icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.edit)),
					contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
					border: OutlineInputBorder(),
					labelText: AppLocales.of(context).translate('$_pageKey.fields.awardName.label')
				),
				maxLength: 120,
				textCapitalization: TextCapitalization.sentences,
				validator: (value) {
					return value.trim().isEmpty ? AppLocales.of(context).translate('$_pageKey.fields.awardName.emptyError') : null;
				},
				onChanged: (val) => setState(() {
					award = award.copyWith(name: val);
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
				decoration: InputDecoration(
					icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.block)),
					contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
					border: OutlineInputBorder(),
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
						WhitelistingTextInputFormatter.digitsOnly
				],
				onChanged: (val) => setState(() {
					award = award.copyWith(limit: int.tryParse(val));
					isDataChanged = true;
				})
			)
		);
	}
	
	Widget buildPointsFields(BuildContext context) {
		return PointPickerField(
			controller: _pointsController,
			pickedCurrency: award.points,
			currencies: currencies,
			loading: false,
			minPoints: 1,
			canBeEmpty: false,
			labelValueText: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.valueLabel'),
			helperValueText: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.hint'),
			labelCurrencyText: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.currencyLabel'),
			pointValueSetter: (val) {
				setState(() {
					isDataChanged = award.points.quantity != ((val != null) ? int.tryParse(val) : null);
					award = award.copyWith(points: award.points.copyWith(quantity: (val != null) ? int.tryParse(val) : null));
				});
			},
			pointCurrencySetter: (val) {
				setState(() {
					isDataChanged = award.points.type != val.type;
					award = award.copyWith(points: award.points.copyWith(type: val.type, title: val.title));
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
				award = award.copyWith(icon: val);
			})
		);
	}

}
