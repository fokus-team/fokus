import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:round_spot/round_spot.dart' as round_spot;
import 'package:smart_select/smart_select.dart';

import '../../logic/caregiver/forms/plan/plan_form_cubit.dart';
import '../../model/db/date/date.dart';
import '../../model/db/date_span.dart';
import '../../model/db/user/child.dart';
import '../../model/ui/app_page.dart';
import '../../model/ui/form/plan_form_model.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/form_config.dart';
import '../../utils/ui/icon_sets.dart';
import '../../utils/ui/theme_config.dart';
import '../buttons/bottom_sheet_confirm_button.dart';
import '../cards/item_card.dart';
import '../general/app_hero.dart';
import 'datepicker_field.dart';

class PlanForm extends StatefulWidget {
	final PlanFormModel plan;
	final Function goNextCallback;

	PlanForm({
		required this.plan,
		required this.goNextCallback
	});

	@override
	_PlanFormState createState() => _PlanFormState();
}

class _PlanFormState extends State<PlanForm> {
	static const String _pageKey = 'page.caregiverSection.planForm.fields';

	bool fieldsValidated = false;

	final TextEditingController _planNameController = TextEditingController();
	final TextEditingController _dateOneDayOnlyController = TextEditingController();
	final TextEditingController _dateRageFromController = TextEditingController();
	final TextEditingController _dateRageToController = TextEditingController();

	String getOnlyDatePart(DateTime? date) => date != null ? date.toLocal().toString().split(' ')[0] : '';

	void setDateCallback(DateTime? pickedDate, Function dateSetter, TextEditingController dateContoller) {
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
					child: round_spot.Detector(
						areaID: 'plan-form-params',
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
					  ),
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
					return value!.trim().isEmpty ? AppLocales.of(context).translate('$_pageKey.planName.emptyError') : null;
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

	Widget getChildrenAssignedField({List<Child> children = const [], bool loading = false}) {
		return SmartSelect<mongo.ObjectId>.multiple(
			title: AppLocales.of(context).translate('$_pageKey.assignedChildren.label'),
			placeholder: AppLocales.of(context).translate('$_pageKey.assignedChildren.hint'),
			selectedValue: widget.plan.children,
			choiceItems: S2Choice.listFrom<mongo.ObjectId, Child>(
				source: children,
				value: (index, item) => item.id!,
				title: (index, item) => item.name!,
				meta: (index, item) => item
			),
			choiceType: S2ChoiceType.chips,
			choiceBuilder: (context, selectState, choice) => Theme(
				data: ThemeData(textTheme: Theme.of(context).textTheme),
				child: ItemCard(
					title: choice.title!,
					subtitle: AppLocales.of(context).translate(choice.selected ? 'actions.selected' : 'actions.tapToSelect'),
					graphicType: AssetType.avatars,
					graphic: choice.meta.avatar,
					graphicShowCheckmark: choice.selected,
					graphicHeight: 44.0,
					onTapped: () => choice.select!(!choice.selected),
					isActive: choice.selected
				)
			),
			choiceEmptyBuilder: (context, selectState) => AppHero(
				icon: Icons.warning,
				header: AppLocales.of(context).translate('$_pageKey.assignedChildren.emptyListHeader'),
				title: AppLocales.of(context).translate('$_pageKey.assignedChildren.emptyListText')
			),
			tileBuilder: (context, selectState) {
				return ListTile(
					leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.people)),
					title: Text(AppLocales.of(context).translate('$_pageKey.assignedChildren.label')),
					subtitle: Text(
						loading ?
							AppLocales.of(context).translate('loading')
							: selectState.selected == null || selectState.selected?.length == 0 ?
								AppLocales.of(context).translate('$_pageKey.assignedChildren.hint')
								: selectState.selected!.title!.join(', '),
						style: TextStyle(color: Colors.grey),
						overflow: TextOverflow.ellipsis,
						maxLines: 1
					),
					enabled: !loading,
					trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
					onTap: () => selectState.showModal()
				);
			},
			modalType: S2ModalType.bottomSheet,
			modalConfig: S2ModalConfig(
				useConfirm: true
			),
			modalConfirmBuilder: (context, selectState) {
				return ButtonSheetConfirmButton(callback: () => selectState.closeModal(confirmed: true));
			},
			onChange: (selected) => setState(() {
				FocusManager.instance.primaryFocus?.unfocus();
				widget.plan.children.clear();
				widget.plan.children = selected!.value!;
			})
		);
	}

	Widget buildRepeatabilityTypeField() {
		return SmartSelect<PlanFormRepeatability>.single(
			title: AppLocales.of(context).translate('$_pageKey.repeatability.label'),
			selectedValue: widget.plan.repeatability,
			choiceItems: [
				for(PlanFormRepeatability element in PlanFormRepeatability.values)
					S2Choice(
						title: AppLocales.of(context).translate('$_pageKey.repeatability.options.${element.toString().split('.').last}'),
						value: element
					)
			],
			modalType: S2ModalType.bottomSheet,
			modalConfig: S2ModalConfig(
				useConfirm: true
			),
			modalConfirmBuilder: (context, selectState) {
				return ButtonSheetConfirmButton(callback: () => selectState.closeModal(confirmed: true));
			},
			tileBuilder: (context, selectState) {
				return ListTile(
					leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.refresh)),
					title: Text(AppLocales.of(context).translate('$_pageKey.repeatability.label')),
					subtitle: Text(
						AppLocales.of(context).translate('$_pageKey.repeatability.options.${selectState.selected?.value.toString().split('.').last}'),
						style: TextStyle(color: Colors.grey),
						overflow: TextOverflow.ellipsis,
						maxLines: 1
					),
					trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
					onTap: () => selectState.showModal()
				);
			},
			onChange: (selected) {
				FocusManager.instance.primaryFocus?.unfocus();
				setState(() => widget.plan.repeatability = selected.value!);
			}
		);
	}

	Widget buildRecurringFields() {
		var isWeekly = widget.plan.repeatabilityRage == PlanFormRepeatabilityRage.weekly;
		var dayList = List<int>.generate(isWeekly ? 7 : 31, (i) => i + 1);

		String daysDisplay(List<int>? values) {
			if(values == null || values.isEmpty)
				return AppLocales.of(context).translate('$_pageKey.days.hint');
			if(values.length == dayList.length)
				return AppLocales.of(context).translate('date.everyday');
			return values.map((e) => 
				isWeekly ? AppLocales.of(context).translate('date.weekday', {'WEEKDAY': e.toString()}) : e.toString()
			).join(', ');
		}

		var dayChoiceList = S2Choice.listFrom<int, int>(
			source: dayList,
			value: (index, item) => item,
			title: (index, item) => isWeekly ? AppLocales.of(context).translate('date.weekday', {'WEEKDAY': item.toString()}) : item.toString()
		);

		return Column(
			children: <Widget>[
				SmartSelect<PlanFormRepeatabilityRage>.single(
					title: AppLocales.of(context).translate('$_pageKey.repeatabilityRange.label'),
					selectedValue: widget.plan.repeatabilityRage,
					choiceItems: [
						for(PlanFormRepeatabilityRage element in PlanFormRepeatabilityRage.values)
							S2Choice(
								title: AppLocales.of(context).translate('$_pageKey.repeatabilityRange.options.${element.toString().split('.').last}'),
								value: element
							)
					],
					modalType: S2ModalType.bottomSheet,
					modalConfig: S2ModalConfig(
						useConfirm: true
					),
					modalConfirmBuilder: (context, selectState) {
						return ButtonSheetConfirmButton(callback: () => selectState.closeModal(confirmed: true));
					},
					tileBuilder: (context, selectState) {
						return ListTile(
							leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.event)),
							title: Text(AppLocales.of(context).translate('$_pageKey.repeatabilityRange.label')),
							subtitle: Text(
								AppLocales.of(context).translate('$_pageKey.repeatabilityRange.options.${selectState.selected?.value.toString().split('.').last}'),
								style: TextStyle(color: Colors.grey),
								overflow: TextOverflow.ellipsis,
								maxLines: 1
							),
							trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
							onTap: () => selectState.showModal()
						);
					},
					onChange: (selected) => setState(() {
						FocusManager.instance.primaryFocus?.unfocus();
						widget.plan.repeatabilityRage = selected.value!;
					}),
				),
				SmartSelect<int>.multiple(
					title: AppLocales.of(context).translate('$_pageKey.days.label${isWeekly ? 'Weekly' : 'Monthly'}'),
					selectedValue: widget.plan.days,
					choiceItems: dayChoiceList,
					choiceType: S2ChoiceType.chips,
					validation: (chosen) {
            if (chosen.isEmpty) return AppLocales.of(context).translate('$_pageKey.days.hint');
            return '';
          },
					modalType: S2ModalType.bottomSheet,
					modalConfig: S2ModalConfig(
						useConfirm: true
					),
					modalFooterBuilder: (context, selectState) {
						return Padding(
							padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
							child: Column(
								children: [
									CheckboxListTile(
										title: Text(AppLocales.of(context).translate('date.everyday')),
										activeColor: selectState.choiceActiveStyle?.color ?? selectState.defaultActiveChoiceStyle.color,
										value: selectState.selection?.length == selectState.choices?.length
											? true : false,
										onChanged: (value) {
											if (value == true) {
												selectState.selection?.clear();
												selectState.selection?.merge(dayChoiceList.toList());
											} else {
												selectState.selection?.clear();
											}
										},
									),
									if(isWeekly)
										CheckboxListTile(
											title: Text(AppLocales.of(context).translate('date.workdays')),
											activeColor: selectState.choiceActiveStyle?.color ?? selectState.defaultActiveChoiceStyle.color,
											value: selectState.selection!.hasAll(dayChoiceList.take(5).toList()) && !selectState.selection!.hasAny(dayChoiceList.skip(5).toList())
												? true : false,
											onChanged: (value) {
												if (value == true) {
													selectState.selection?.clear();
													selectState.selection?.merge(dayChoiceList.take(5).toList());
												} else {
													selectState.selection?.clear();
												}
											},
										)
								]
							)
						);
					},
					modalConfirmBuilder: (context, selectState) {
						return ButtonSheetConfirmButton(callback: () => selectState.closeModal(confirmed: true));
					},
					tileBuilder: (context, selectState) {
						return ListTile(
							leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.date_range)),
							title: Text(AppLocales.of(context).translate('$_pageKey.days.label${isWeekly ? 'Weekly' : 'Monthly'}')),
							subtitle: Text(
								daysDisplay(selectState.selected!.value),
								style: TextStyle(color: (fieldsValidated && widget.plan.days.isEmpty) ? Theme.of(context).errorColor : Colors.grey),
								overflow: TextOverflow.ellipsis,
								maxLines: 1
							),
							trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
							onTap: () => selectState.showModal()
						);
					},
					onChange: (selected) {
						FocusManager.instance.primaryFocus?.unfocus();
						setState(() => { widget.plan.days = selected!.value! });
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
									TextButton(
										onPressed: () {
											setState(() => fieldsValidated = true);
											widget.goNextCallback();
										},
										style: TextButton.styleFrom(
											primary: AppColors.mainBackgroundColor
										),
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
