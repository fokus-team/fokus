import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/caregiver/forms/reward/reward_form_cubit.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/form_config.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/forms/iconpicker_field.dart';
import 'package:fokus/widgets/forms/pointpicker_field.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';

class CaregiverRewardFormPage extends StatefulWidget {
	@override
	_CaregiverRewardFormPageState createState() => new _CaregiverRewardFormPageState();
}

class _CaregiverRewardFormPageState extends State<CaregiverRewardFormPage> {
	static const String _pageKey = 'page.caregiverSection.rewardForm';
	late AppFormType _formType;
	late GlobalKey<FormState> rewardFormKey;

	TextEditingController _titleController = TextEditingController();
	TextEditingController _limitController = TextEditingController();
	TextEditingController _pointsController = TextEditingController();

	@override
  void initState() {
		rewardFormKey = GlobalKey<FormState>();
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
		_formType = context.watch<RewardFormCubit>().state.formType;
		return Scaffold(
			appBar: AppBar(
				backgroundColor: AppColors.formColor,
				title: Text(AppLocales.of(context).translate(
					_formType == AppFormType.create ? '$_pageKey.addRewardTitle' : '$_pageKey.editRewardTitle'
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
								child: _buildFormFields()
							)
						)
					),
					Positioned.fill(
						top: null,
						child: _buildBottomNavigation()
					)
				]
			)
		);
	}

	Widget _buildBottomNavigation() {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
			decoration: AppBoxProperties.elevatedContainer,
			height: AppBoxProperties.standardBottomNavHeight,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.end,
				children: <Widget>[
					SizedBox.shrink(),
					TextButton(
						onPressed: () {
							if(rewardFormKey.currentState!.validate())
								context.read<RewardFormCubit>().submitRewardForm();
						},
						child: Text(
							AppLocales.of(context).translate(_formType == AppFormType.create ? '$_pageKey.addRewardButton' : '$_pageKey.saveRewardButton'),
							style: Theme.of(context).textTheme.button?.copyWith(color: AppColors.mainBackgroundColor)
						)
					)
				]
			)
		);
	}

	Widget _buildFormFields() {
		return StatefulBlocBuilder<RewardFormCubit, BaseFormState, RewardFormDataLoadSuccess>(
			listener: (context, state) {
				if (state.submitted)
					showSuccessSnackbar(context, 'page.caregiverSection.awards.content.reward${_formType == AppFormType.create ? 'Added' : 'Updated'}Text');
				else if (state is RewardFormDataLoadSuccess && !state.wasDataChanged)
					setState(() {
						_titleController.text = state.reward.name ?? '';
						_limitController.text = state.reward.limit?.toString() ?? '';
						_pointsController.text = state.reward.cost?.quantity?.toString() ?? '';
					});
			},
			popConfig: SubmitPopConfig.onSubmitted(),
			builder: (context, state) => WillPopScope(
				onWillPop: () async {
					bool? ret = await showExitFormDialog(context, true, state.wasDataChanged);
					if(ret == null || !ret) return false;
					else return true;
				},
				child: _buildForm(state)
			),
			loadingBuilder: (context, state) => _buildForm(),
			overlayLoader: true,
		);
	}

	Widget _buildForm([RewardFormDataLoadSuccess? state]) {
		return ListView(
			shrinkWrap: true,
			children: <Widget>[
				_buildNameField(),
				_buildLimitField(),
				_buildPointsFields(state),
				_buildIconField(state)
			]
		);
	}

	Widget _buildNameField() {
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
					return value!.trim().isEmpty ? AppLocales.of(context).translate('$_pageKey.fields.rewardName.emptyError') : null;
				},
				onChanged: (val) => context.read<RewardFormCubit>().onRewardChanged((reward) => reward.copyWith(name: val))
			)
		);
	}

	Widget _buildLimitField() {
		return Padding(
			padding: EdgeInsets.only(top: 5.0, bottom: 16.0, left: 20.0, right: 20.0),
			child: TextFormField(
				controller: _limitController,
				decoration: AppFormProperties.textFieldDecoration(Icons.block).copyWith(
					labelText: AppLocales.of(context).translate('$_pageKey.fields.rewardLimit.label'),
					hintText: '0',
					helperText: AppLocales.of(context).translate('$_pageKey.fields.rewardLimit.hint'),
					helperMaxLines: 3,
					errorMaxLines: 3,
					suffixIcon: IconButton(
						onPressed: () {
							FocusScope.of(context).requestFocus(FocusNode());
							_limitController.clear();
						},
						icon: Icon(Icons.clear)
					)
				),
				validator: (value) {
					return int.tryParse(value!) == 0 ? AppLocales.of(context).translate('$_pageKey.fields.rewardLimit.zeroError') : null;
				},
				keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
				inputFormatters: <TextInputFormatter>[
					FilteringTextInputFormatter.digitsOnly,
					LengthLimitingTextInputFormatter(9),
				],
				onChanged: (String? val) => context.read<RewardFormCubit>().onRewardChanged((reward) => reward.copyWith(limit: val != null ? int.tryParse(val) : null))
			)
		);
	}
	
	Widget _buildPointsFields([RewardFormDataLoadSuccess? state]) {
		var onCostChanged = (UIPoints Function(UIPoints) change) => context.read<RewardFormCubit>().onRewardChanged((reward) => reward.copyWith(cost: change(reward.cost!)));
		return PointPickerField(
			controller: _pointsController,
			pickedCurrency: state?.reward.cost,
			currencies: state?.currencies,
			loading: state == null,
			minPoints: 1,
			canBeEmpty: false,
			labelValueText: AppLocales.of(context).translate('$_pageKey.fields.rewardPoints.valueLabel'),
			helperValueText: AppLocales.of(context).translate('$_pageKey.fields.rewardPoints.hint'),
			labelCurrencyText: AppLocales.of(context).translate('$_pageKey.fields.rewardPoints.currencyLabel'),
			pointValueSetter: (String? val) => onCostChanged((cost) => cost.copyWith(quantity: val != null ? int.tryParse(val) : null)),
			pointCurrencySetter: (val) => onCostChanged((cost) => cost.copyWith(type: val.type)),
		);
	}

	Widget _buildIconField([RewardFormDataLoadSuccess? state]) {
		return IconPickerField.reward(
			title: AppLocales.of(context).translate('$_pageKey.fields.rewardIcon.label'),
			groupTextKey: '$_pageKey.fields.rewardIcon.groups',
			value: state != null ? state.reward.icon! : 1,
			callback: (val) {
				context.read<RewardFormCubit>().onRewardChanged((reward) => reward.copyWith(icon: val));
			  setState(() => FocusManager.instance.primaryFocus?.unfocus());
			}
		);
	}

}
