import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/reward_form/reward_form_cubit.dart';
import 'package:fokus/model/ui/form/reward_form_model.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/form_config.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/utils/snackbar_utils.dart';
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
	AppFormType formType;
	GlobalKey<FormState> rewardFormKey;
	bool isDataChanged = false;

	RewardFormModel reward = RewardFormModel();

	TextEditingController _titleController = TextEditingController();
	TextEditingController _limitController = TextEditingController();
	TextEditingController _pointsController = TextEditingController();

	@override
  void initState() {
		rewardFormKey = GlobalKey<FormState>();
		reward.pointCurrency = UICurrency(type: CurrencyType.diamond);
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
		return BlocConsumer<RewardFormCubit, RewardFormState>(
			listener: (context, state) {
				if (state is RewardFormSubmissionSuccess) {
					Navigator.of(context).pop();
					showSuccessSnackbar(context, 'page.caregiverSection.awards.content.reward${formType == AppFormType.create ? 'Added' : 'Updated'}Text');
				} else if (state is RewardFormDataLoadSuccess)
					setState(() {
						reward = RewardFormModel.from(state.rewardForm);
						_titleController.text = reward.name ?? '';
						_limitController.text = reward.limit != null ? reward.limit.toString() : '';
						_pointsController.text = reward.pointValue != null ? reward.pointValue.toString() : '';
					});
			},
	    builder: (context, state) {
				if (state is RewardFormInitial) {
					formType = state.formType;
					context.bloc<RewardFormCubit>().loadFormData();
				}
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
		);
	}

	void saveReward(BuildContext context) {
		if(rewardFormKey.currentState.validate()) {
			context.bloc<RewardFormCubit>().submitRewardForm(reward);
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
						onPressed: () => saveReward(context),
						child: Text(
							AppLocales.of(context).translate(formType == AppFormType.create ? '$_pageKey.addRewardButton' : '$_pageKey.saveRewardButton'),
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
				BlocBuilder<RewardFormCubit, RewardFormState>(
		  		builder: (context, state) {
		  			if (state is RewardFormDataLoadSuccess)
		  				return buildPointsFields(currencies: state.currencies);
						return buildPointsFields(loading: state.formType == AppFormType.create);
					}
				),
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
					reward.name = val;
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
					reward.limit = val != null ? int.tryParse(val) : null;
					isDataChanged = true;
				})
			)
		);
	}
	
	Widget buildPointsFields({List<UICurrency> currencies = const [], bool loading = false}) {
		return PointPickerField(
			controller: _pointsController,
			pickedCurrency: reward.pointCurrency,
			currencies: currencies,
			loading: loading,
			minPoints: 1,
			canBeEmpty: false,
			labelValueText: AppLocales.of(context).translate('$_pageKey.fields.rewardPoints.valueLabel'),
			helperValueText: AppLocales.of(context).translate('$_pageKey.fields.rewardPoints.hint'),
			labelCurrencyText: AppLocales.of(context).translate('$_pageKey.fields.rewardPoints.currencyLabel'),
			pointValueSetter: (val) {
				setState(() {
					reward.pointValue = val != null ? int.tryParse(val) : null;
					isDataChanged = true;
				});
			},
			pointCurrencySetter: (val) {
				setState(() {
					reward.pointCurrency = val;
					isDataChanged = true;
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
				reward.icon = val;
				isDataChanged = true;
			})
		);
	}

}
