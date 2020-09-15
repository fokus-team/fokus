import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/form_config.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/forms/iconpicker_field.dart';
import 'package:fokus/widgets/forms/pointpicker_field.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class CaregiverRewardFormPage extends StatefulWidget {
	@override
	_CaregiverRewardFormPageState createState() => new _CaregiverRewardFormPageState();
}

class _CaregiverRewardFormPageState extends State<CaregiverRewardFormPage> {
	static const String _pageKey = 'page.caregiverSection.rewardForm';
	AppFormType formType = AppFormType.create; // only create for now
	GlobalKey<FormState> rewardFormKey;
	bool isDataChanged = false;

	UIReward reward;

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
		rewardFormKey = GlobalKey<FormState>();
		reward = UIReward(cost: UIPoints(type: currencies[0].type, title: currencies[0].title));
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
						formType == AppFormType.create ? '$_pageKey.addRewardTitle' : '$_pageKey.editRewardTitle'
					)),
					actions: <Widget>[
						HelpIconButton(helpPage: 'reward_creation')
					]
				),
				body: Stack(
					children: [
						Positioned.fill(
							bottom: AppBoxProperties.standardBottomNavHeight,
							child: Form(
								key: rewardFormKey,
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

	void saveReward(BuildContext context) {
		if(rewardFormKey.currentState.validate()) {
			// TODO adding/saving logic
			Navigator.of(context).pop();
		}
	}

	void removeReward(BuildContext context) {
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
							onPressed: () => removeReward(context),
							child: Text(
								AppLocales.of(context).translate('$_pageKey.removeRewardButton'),
								style: Theme.of(context).textTheme.button.copyWith(color: Colors.red)
							)
						) : SizedBox.shrink(),
					FlatButton(
						onPressed: () => saveReward(context),
						child: Text(
							AppLocales.of(context).translate(formType == AppFormType.create ? '$_pageKey.addRewardButton' : '$_pageKey.saveRewardButton' ),
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
					labelText: AppLocales.of(context).translate('$_pageKey.fields.rewardName.label')
				),
				maxLength: AppFormProperties.textFieldMaxLength,
				textCapitalization: TextCapitalization.sentences,
				validator: (value) {
					return value.trim().isEmpty ? AppLocales.of(context).translate('$_pageKey.fields.rewardName.emptyError') : null;
				},
				onChanged: (val) => setState(() {
					reward = reward.copyWith(name: val);
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
					labelText: AppLocales.of(context).translate('$_pageKey.fields.rewardLimit.label'),
					hintText: '0',
					helperText: AppLocales.of(context).translate('$_pageKey.fields.rewardLimit.hint'),
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
					reward = reward.copyWith(limit: int.tryParse(val));
					isDataChanged = true;
				})
			)
		);
	}
	
	Widget buildPointsFields(BuildContext context) {
		return PointPickerField(
			controller: _pointsController,
			pickedCurrency: reward.cost,
			currencies: currencies,
			loading: false,
			minPoints: 1,
			canBeEmpty: false,
			labelValueText: AppLocales.of(context).translate('$_pageKey.fields.rewardPoints.valueLabel'),
			helperValueText: AppLocales.of(context).translate('$_pageKey.fields.rewardPoints.hint'),
			labelCurrencyText: AppLocales.of(context).translate('$_pageKey.fields.rewardPoints.currencyLabel'),
			pointValueSetter: (val) {
				setState(() {
					isDataChanged = reward.cost.quantity != ((val != null) ? int.tryParse(val) : null);
					reward = reward.copyWith(cost: reward.cost.copyWith(quantity: (val != null) ? int.tryParse(val) : null));
				});
			},
			pointCurrencySetter: (val) {
				setState(() {
					isDataChanged = reward.cost.type != val.type;
					reward = reward.copyWith(cost: reward.cost.copyWith(type: val.type, title: val.title));
				});
			},
		);
	}

	Widget buildIconField(BuildContext context) {
		return IconPickerField.reward(
			title: AppLocales.of(context).translate('$_pageKey.fields.rewardIcon.label'),
			groupTextKey: '$_pageKey.fields.rewardIcon.groups',
			value: reward.icon,
			callback: (val) => setState(() {
				FocusManager.instance.primaryFocus.unfocus();
				reward = reward.copyWith(icon: val);
			})
		);
	}

}
