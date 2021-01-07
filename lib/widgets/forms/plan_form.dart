import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/caregiver/plan_form/plan_form_cubit.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/pages/app_form_type.dart';
import 'package:fokus/utils/ui/form_config.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_confirm_button.dart';
import 'package:smart_select/smart_select.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/model/ui/form/plan_form_model.dart';
import 'package:fokus/model/ui/user/ui_child.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/theme_config.dart';

import 'package:fokus/widgets/forms/datepicker_field.dart';
import 'package:fokus/widgets/cards/item_card.dart';

class PlanForm extends StatefulWidget {
	final PlanFormModel plan;
	final Function goNextCallback;

	PlanForm({
		@required this.plan,
		@required this.goNextCallback
	});

	@override
	_PlanFormState createState() => new _PlanFormState();
}

class _PlanFormState extends State<PlanForm> {
	static const String _pageKey = 'page.caregiverSection.planForm.fields';

	bool fieldsValidated = false;

	TextEditingController _planNameController = TextEditingController();
	TextEditingController _dateOneDayOnlyController = TextEditingController();
	TextEditingController _dateRageFromController = TextEditingController();
	TextEditingController _dateRageToController = TextEditingController();

	String getOnlyDatePart(DateTime date) => date != null ? date.toLocal().toString().split(' ')[0] : '';

	void setDateCallback(DateTime pickedDate, Function dateSetter, TextEditingController dateContoller) {
		setState(() {
			dateSetter(pickedDate);
			dateContoller.value = TextEditingValue(text: getOnlyDatePart(pickedDate));
		});
	}
	
  @override
	void initState() {
		_planNameController.text = widget.plan.name ?? '';
		_dateOneDayOnlyController.text = widget.plan.onlyOnceDate != null ? getOnlyDatePart(widget.plan.onlyOnceDate) : '';
		_dateRageFromController.text = widget.plan.rangeDate.from != null ? getOnlyDatePart(widget.plan.rangeDate.from) : '';
		_dateRageToController.text = widget.plan.rangeDate.to != null ? getOnlyDatePart(widget.plan.rangeDate.to) : '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
			children: [
				Positioned.fill(
					bottom: AppBoxProperties.standardBottomNavHeight,
					child: ListView(
						shrinkWrap: true,
						children: <Widget>[
							buildPlanNameField(),
							buildChildrenAssignedField(),
							Divider(),
							buildRepeatabilityTypeField(),
							if(widget.plan.repeatability == PlanFormRepeatability.recurring)
								buildRecurringFields()
							else if(widget.plan.repeatability == PlanFormRepeatability.onlyOnce)
								buildOneDayOnlyFields()
							else
								buildUntilCompletedFields()
						]
					)
				),
				Positioned.fill(
					top: null,
					child: buildBottomNavigation()
				)
			]
		);
  }

	Widget buildPlanNameField() {
		return Padding(
			padding: EdgeInsets.only(top: 25.0, bottom: 10.0, left: 20.0, right: 20.0),
			child: TextFormField(
				controller: _planNameController,
				decoration: AppFormProperties.textFieldDecoration(Icons.edit).copyWith(
					labelText: AppLocales.of(context).translate('$_pageKey.planName.label')
				),
				maxLength: AppFormProperties.textFieldMaxLength,
				textCapitalization: TextCapitalization.sentences,
				validator: (value) {
					return value.trim().isEmpty ? AppLocales.of(context).translate('$_pageKey.planName.emptyError') : null;
				},
				onChanged: (val) => setState(() => widget.plan.name = val)
			)
		);
	}

	Widget buildChildrenAssignedField() {
		return BlocBuilder<PlanFormCubit, PlanFormState>(
		  builder: (context, state) {
		  	if (state is PlanFormDataLoadSuccess)
		  		return getChildrenAssignedField(children: state.children);
		  	return getChildrenAssignedField(loading: state.formType == AppFormType.create);
			}
		);
	}

	Widget getChildrenAssignedField({List<UIChild> children = const [], bool loading = false}) {
		return SmartSelect<Mongo.ObjectId>.multiple(
			title: AppLocales.of(context).translate('$_pageKey.assignedChildren.label'),
			placeholder: AppLocales.of(context).translate('$_pageKey.assignedChildren.hint'),
			value: widget.plan.children,
			options: SmartSelectOption.listFrom<Mongo.ObjectId, UIChild>(
				source: children,
				value: (index, item) => item.id,
				title: (index, item) => item.name,
				meta: (index, item) => item
			),
			isTwoLine: true,
			isLoading: loading,
			loadingText: AppLocales.of(context).translate('loading'),
			choiceType: SmartSelectChoiceType.chips,
			choiceConfig: SmartSelectChoiceConfig(
				builder: (item, checked, onChange) => Theme(
					data: ThemeData(textTheme: Theme.of(context).textTheme),
					child: ItemCard(
						title: item.title,
						subtitle: AppLocales.of(context).translate(checked ? 'actions.selected' : 'actions.tapToSelect'),
						graphicType: AssetType.avatars,
						graphic: item.meta.avatar,
						graphicShowCheckmark: checked,
						graphicHeight: 44.0,
						onTapped: onChange != null ? () => onChange(item.value, !checked) : null,
						isActive: checked
					)
				)
			),
			modalType: SmartSelectModalType.bottomSheet,
			modalConfig: SmartSelectModalConfig(
				searchBarHint: AppLocales.of(context).translate('actions.search'),
				useConfirmation: true,
				confirmationBuilder: (context, callback) => ButtonSheetConfirmButton(callback: () => callback)
			),
			leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.people)),
			onChange: (val) => setState(() {
				FocusManager.instance.primaryFocus.unfocus();
				widget.plan.children.clear();
				widget.plan.children = val;
			})
		);
	}

	void onSelectAll(List<dynamic> sourceList, List<dynamic> valueList) {
		// TODO Smart Select is really stuborn, fix state overwriting 
		if(sourceList.length == valueList.length) {
			setState(() {
				valueList.clear();
			});
		} else {
			setState(() {
				valueList.clear();
				valueList.addAll(sourceList);
			});
		}
	}

	Widget buildRepeatabilityTypeField() {
		return SmartSelect<PlanFormRepeatability>.single(
			title: AppLocales.of(context).translate('$_pageKey.repeatability.label'),
			value: widget.plan.repeatability,
			options: [
				for(PlanFormRepeatability element in PlanFormRepeatability.values)
					SmartSelectOption(
						title: AppLocales.of(context).translate('$_pageKey.repeatability.options.${element.toString().split('.').last}'),
						value: element
					)
			],
			isTwoLine: true,
			modalType: SmartSelectModalType.bottomSheet,
			modalConfig: SmartSelectModalConfig(
				useConfirmation: true,
				confirmationBuilder: (context, callback) => ButtonSheetConfirmButton(callback: () => callback)
			),
			leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.refresh)),
			onChange: (val) {
				FocusManager.instance.primaryFocus.unfocus();
				setState(() => widget.plan.repeatability = val);
			}
		);
	}

	Widget buildRecurringFields() {
		bool isWeekly = widget.plan.repeatabilityRage == PlanFormRepeatabilityRage.weekly;
		List<int> dayList = List<int>.generate(isWeekly ? 7 : 31, (i) => i + 1);

		String daysDisplay(List<int> values) {
			if(values.isEmpty)
				return AppLocales.of(context).translate('$_pageKey.days.hint');
			if(values.length == dayList.length)
				return AppLocales.of(context).translate('date.everyday');
			return values.map((e) => 
				isWeekly ? AppLocales.of(context).translate('date.weekday', {'WEEKDAY': e.toString()}) : e.toString()
			).join(', ');
		}

		return Column(
			children: <Widget>[
				SmartSelect<PlanFormRepeatabilityRage>.single(
					title: AppLocales.of(context).translate('$_pageKey.repeatabilityRange.label'),
					value: widget.plan.repeatabilityRage,
					options: [
						for(PlanFormRepeatabilityRage element in PlanFormRepeatabilityRage.values)
							SmartSelectOption(
								title: AppLocales.of(context).translate('$_pageKey.repeatabilityRange.options.${element.toString().split('.').last}'),
								value: element
							)
					],
					isTwoLine: true,
					modalType: SmartSelectModalType.bottomSheet,
					modalConfig: SmartSelectModalConfig(
						useConfirmation: true,
						confirmationBuilder: (context, callback) => ButtonSheetConfirmButton(callback: () => callback)
					),
					leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.event)),
					onChange: (val) => setState(() {
						FocusManager.instance.primaryFocus.unfocus();
						widget.plan.repeatabilityRage = val;
						widget.plan.days.clear();
					}),
				),
				SmartSelect<int>.multiple(
					title: AppLocales.of(context).translate('$_pageKey.days.label${isWeekly ? 'Weekly' : 'Monthly'}'),
					value: widget.plan.days,
					options: SmartSelectOption.listFrom<int, int>(
						source: dayList,
						value: (index, item) => item,
						title: (index, item) => isWeekly ? AppLocales.of(context).translate('date.weekday', {'WEEKDAY': item.toString()}) : item.toString()
					),
					choiceType: SmartSelectChoiceType.chips,
					modalType: SmartSelectModalType.bottomSheet,
					modalConfig: SmartSelectModalConfig(
						useConfirmation: true,
						confirmationBuilder: (context, callback) => ButtonSheetConfirmButton(callback: () => callback)
					),
					builder: (context, state, callback) {
						return ListTile(
							leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.date_range)),
							title: Text(AppLocales.of(context).translate('$_pageKey.days.label${isWeekly ? 'Weekly' : 'Monthly'}')),
							subtitle: Text(
								daysDisplay(state.values),
								style: TextStyle(color: (fieldsValidated && widget.plan.days.isEmpty) ? Theme.of(context).errorColor : Colors.grey),
								overflow: TextOverflow.ellipsis,
								maxLines: 1
							),
							trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
							onTap: () => callback(context)
						);
					},
					onChange: (val) {
						FocusManager.instance.primaryFocus.unfocus();
						setState(() => { widget.plan.days = val });
					}
				),
				Divider(),
				buildDateRangeFields()
			],
		);
	}

	Widget buildOneDayOnlyFields() {
		return Padding(
			padding: EdgeInsets.only(top: 8.0),
			child: DatePickerField(
				labelText: AppLocales.of(context).translate('$_pageKey.onlyOneDate.label'),
				errorText: AppLocales.of(context).translate('$_pageKey.onlyOneDate.emptyError'),
				dateController: _dateOneDayOnlyController,
				dateSetter: widget.plan.setOnlyOnceDate, 
				callback: setDateCallback,
				canBeEmpty: false
			)
		);
	}

	Widget buildUntilCompletedFields() {
		return buildDateRangeFields();
	}

	Widget buildDateRangeFields() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				Padding(
					padding: EdgeInsets.only(top: 8.0, bottom: 12.0, left: 20.0),
					child: Text(
						AppLocales.of(context).translate('$_pageKey.advancedOptionsTitle'),
						style: TextStyle(fontWeight: FontWeight.bold)
					)
				),
				Padding(
					padding: EdgeInsets.only(top: 8.0),
					child: DatePickerField(
						icon: Icons.event_note,
						labelText: AppLocales.of(context).translate('$_pageKey.range.fromLabel'),
						rangeDate: DateSpan<Date>(to: widget.plan.rangeDate.to),
						dateController: _dateRageFromController,
						dateSetter: widget.plan.setRangeFromDate, 
						callback: setDateCallback
					)
				),
				Padding(
					padding: EdgeInsets.only(top: 8.0),
					child: DatePickerField(
						icon: Icons.event_note,
						labelText: AppLocales.of(context).translate('$_pageKey.range.toLabel'),
						helperText: AppLocales.of(context).translate('$_pageKey.range.hint'),
						rangeDate: DateSpan<Date>(from: widget.plan.rangeDate.from),
						dateController: _dateRageToController,
						dateSetter: widget.plan.setRangeToDate,
						callback: setDateCallback
					)
				),
				Padding(
					padding: EdgeInsets.only(top: 12.0),
					child: SwitchListTile(
						value: widget.plan.isActive,
						title: Text(AppLocales.of(context).translate('$_pageKey.active.label')),
						subtitle: Text(AppLocales.of(context).translate('$_pageKey.active.${widget.plan.isActive ? 'hintOn' : 'hintOff'}')),
						secondary: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.lightbulb_outline)),
						onChanged: (val) => setState(() => widget.plan.isActive = val)
					)
				),
			]
		);
	}

	Widget buildBottomNavigation() {
		return Container(
			height: AppBoxProperties.standardBottomNavHeight,
			child: Stack(
				children: [
					Positioned(
						bottom: 0,
						left: 0,
						right: 0,
						child: Container(
							padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
							decoration: AppBoxProperties.elevatedContainer,
							height: AppBoxProperties.standardBottomNavHeight,
							child: Row(
								mainAxisAlignment: MainAxisAlignment.end,
								crossAxisAlignment: CrossAxisAlignment.end,
								children: <Widget>[
									FlatButton(
										onPressed: () {
											setState(() => fieldsValidated = true);
											widget.goNextCallback();
										},
										textColor: AppColors.mainBackgroundColor,
										child: Row(children: <Widget>[Text(AppLocales.of(context).translate('actions.next')), Icon(Icons.chevron_right)])
									)
								]
							)
						)
					)
				]
			)
		);
	}

}
