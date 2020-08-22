import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/award/ui_award.dart';
import 'package:fokus/model/ui/ui_currency.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:smart_select/smart_select.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
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
		award = UIAward(key: ValueKey(DateTime.now()));
		award.pointCurrency = currencies[0];
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
					award.limit = int.tryParse(val);
					isDataChanged = true;
				})
			)
		);
	}
	
	Widget buildPointsFields(BuildContext context) {
		return SmartSelect<UICurrency>.single(
			builder: (context, state, function) {
				return Padding(
					padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 20.0, right: 16.0),
					child: Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								child: TextFormField(
									controller: _pointsController,
									decoration: InputDecoration(
										icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.star)),
										contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
										border: OutlineInputBorder(),
										hintText: "0",
										helperMaxLines: 3,
										errorMaxLines: 3,
										helperText: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.hint'),
										labelText: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.valueLabel'),
										suffixIcon: IconButton(
											onPressed: () {
												FocusScope.of(context).requestFocus(FocusNode());
												_pointsController.clear();
											},
											icon: Icon(Icons.clear)
										)
									),
									validator: (value) {
										final range = [1, 1000000];
										final int numValue = int.tryParse(value);
										return (numValue != null && (numValue < range[0] || numValue > range[1])) ? 
											AppLocales.of(context).translate('alert.genericRangeOverflowValue', {'A': range[0].toString(), 'B': range[1].toString()})
											: null;
									},
									keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
									inputFormatters: <TextInputFormatter>[
											WhitelistingTextInputFormatter.digitsOnly
									],
									onChanged: (val) => setState(() {
										award.pointValue = int.tryParse(val);
										isDataChanged = true;
									})
								)
							),
							GestureDetector(
								onTap: () {
									if(currencies.length > 1) {
										FocusManager.instance.primaryFocus.unfocus();
										function(context);
									}
								},
								child: Tooltip(
									message: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.currencyLabel'),
									child: Row(
										children: <Widget>[
											Padding(
												padding: EdgeInsets.only(left: 10.0, top: 4.0),
												child: CircleAvatar(
													child: SvgPicture.asset(currencySvgPath(state.value.type), width: 28, fit: BoxFit.cover),
													backgroundColor: AppColors.currencyColor[state.value.type].withAlpha(50)
												)
											),
											if(currencies.length > 1) 
												Padding(
													padding: EdgeInsets.only(left: 4.0, top: 2.0),
													child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
												)
										]
									)
								)
							)
						]
					)
				);
			},
			title: AppLocales.of(context).translate('$_pageKey.fields.awardPoints.currencyLabel'),
			value: award.pointCurrency,
			options: [
				for(UICurrency element in currencies)
					SmartSelectOption(
						title: element.title,
						value: element
					)
			],
			choiceConfig: SmartSelectChoiceConfig(
				builder: (item, checked, onChange) {
					return RadioListTile<UICurrency>(
						value: item.value,
						groupValue: award.pointCurrency,
						onChanged: (val) => {onChange(item.value, !checked)},
						title: Row(
							children: [
								Padding(
									padding: EdgeInsets.only(right: 6.0),
									child: SvgPicture.asset(currencySvgPath(item.value.type), width: 30, fit: BoxFit.cover)
								),
								Text(item.value.title, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.currencyColor[item.value.type]))
							]
						)
					);
				}
			),
			modalType: SmartSelectModalType.bottomSheet,
			onChange: (val) => setState(() => award.pointCurrency = val)
		);
	}

	Widget buildIconField(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(vertical: 10.0),
			child: SmartSelect<int>.single(
				leading: SvgPicture.asset(awardIconSvgPath(award.icon), height: 74.0),
				title: AppLocales.of(context).translate('$_pageKey.fields.awardIcon.label'),
				value: award.icon,
				options: List.generate(awardIcons.length, (index) {
						final String name = AppLocales.of(context).translate('$_pageKey.fields.awardIcon.groups.${awardIcons[index].label.toString().split('.').last}');
						return SmartSelectOption(
							title: name,
							group: name,
							value: index
						);
					}
				),
				isTwoLine: true,
				choiceConfig: SmartSelectChoiceConfig(
					glowingOverscrollIndicatorColor: Colors.teal,
					runSpacing: 10.0,
					spacing: 10.0,
					useWrap: true,
					isGrouped: true,
					builder: (item, checked, onChange) {
						return Badge(
							badgeContent: Icon(Icons.check, color: Colors.white, size: 16.0),
							badgeColor: Colors.green,
							animationType: BadgeAnimationType.scale,
							showBadge: checked != null ? checked : false,
							child: GestureDetector(
								onTap: () => { onChange(item.value, !checked) },
								child: SvgPicture.asset(awardIconSvgPath(item.value), height: 64.0)
							)
						);
					}
				),
				modalType: SmartSelectModalType.bottomSheet,
				onChange: (val) => setState(() {
					FocusManager.instance.primaryFocus.unfocus();
					award.icon = val;
				})
			)
		);
	}

}
