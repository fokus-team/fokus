import 'package:flutter/material.dart';
import 'package:fokus/model/ui/plan/ui_plan_form.dart';
import 'package:fokus/model/ui/user/ui_child.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/forms/datepicker_field.dart';

import 'package:fokus/widgets/item_card.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:smart_select/smart_select.dart';

class PlanForm extends StatefulWidget {
	final UIPlanForm plan;

	PlanForm({
		@required this.plan
	});

	@override
	_PlanFormState createState() => new _PlanFormState();

}

class _PlanFormState extends State<PlanForm> {
	static const String _pageKey = 'page.caregiverSection.planForm.fields';

	TextEditingController _planNameContoller = TextEditingController();
	TextEditingController _dateOneDayOnlyContoller = TextEditingController();
	TextEditingController _dateRageFromContoller = TextEditingController();
	TextEditingController _dateRageToContoller = TextEditingController();

	List<UIChild> children = [
		UIChild(Mongo.ObjectId.fromSeconds(1), "Mateusz", avatar: 5),
		UIChild(Mongo.ObjectId.fromSeconds(2), "Gosia", avatar: 23),
		UIChild(Mongo.ObjectId.fromSeconds(3), "Andżelika", avatar: 21),
		UIChild(Mongo.ObjectId.fromSeconds(4), "Joanna", avatar: 24)
	];

	void setDateCallback(Future<DateTime> pickedDate, DateTime dateField, TextEditingController dateContoller) {
		pickedDate.then((value) => {
			if (value != null && value != dateField)
				setState(() { 
					dateField = value; 
					dateContoller.value = TextEditingValue(text: value.toLocal().toString().split(' ')[0]);
				})
		});
	}

  @override
  Widget build(BuildContext context) {
    return Column(
			children: <Widget>[
				buildPlanNameField(context),
				buildChildrenAssignedField(context),
				Divider(),
				buildRepeatabilityTypeField(context),
				if(widget.plan.repeatability == PlanFormRepeatability.recurring)
					buildRecurringFields(context)
				else if(widget.plan.repeatability == PlanFormRepeatability.onlyOnce)
					buildOneDayOnlyFields(context)
				else
					buildUntilCompletedFields(context)
			]
    );
  }

	Widget buildPlanNameField(BuildContext context) {
		return TextFormField(
			controller: _planNameContoller,
			decoration: InputDecoration(
				icon: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.description)),
				contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
				border: OutlineInputBorder(),
				labelText: AppLocales.of(context).translate('$_pageKey.planName.label')
			),
			maxLength: 120,
			validator: (value) {
				return value.isEmpty ? AppLocales.of(context).translate('$_pageKey.planName.emptyError') : null;
			},
			onChanged: (val) => setState(() => widget.plan.name = val)
		);
	}

	Widget buildChildrenAssignedField(BuildContext context) {
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
			padding: EdgeInsets.zero,
			choiceType: SmartSelectChoiceType.chips,
			choiceConfig: SmartSelectChoiceConfig(
				builder: (item, checked, onChange) => 
					Theme(
						data: ThemeData(textTheme: Theme.of(context).textTheme),
						child: ItemCard(
							title: item.title,
							subtitle: AppLocales.of(context).translate(checked ? 'actions.selected' : 'actions.tapToSelect'),
							graphicType: GraphicAssetType.childAvatars,
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
				trailing: buildBottomSheetBar(context, children.length > 1, children, widget.plan.children)
			),
			leading: Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.people)),
			onChange: (val) => setState(() => widget.plan.children = val)
		);
	}

	Widget buildBottomSheetBarButton(Color color, IconData icon, String text, Function onPressed) {
		return Expanded(
			child: RaisedButton(
				shape: ContinuousRectangleBorder(),
				padding: EdgeInsets.symmetric(vertical: 12.0),
				color: color,
				child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Padding(
							padding: EdgeInsets.only(right: AppBoxProperties.buttonIconPadding),
							child: Icon(icon, color: Colors.white)
						),
						Text(text, style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white))
					]
				),
				materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
				onPressed: onPressed
			)
		);
	}

	Widget buildBottomSheetBar(BuildContext context, bool selectAllButton, List<dynamic> sourceList, List<dynamic> valueList) {
		/* SELECT ALL
		Function onSelectAll = () {
			if(sourceList.length == valueList.length) {
				setState(() => valueList.clear());
			} else {
				setState(() => valueList.clear());
				List<Mongo.ObjectId> allChildren = List<Mongo.ObjectId>();
				sourceList.forEach((element) {
					allChildren.add(element.id);
				});
				setState(() => valueList = allChildren);
			}
		};
		*/
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceEvenly,
			children: [
				/* SELECT ALL
				if(selectAllButton)
					if(sourceList.length == valueList.length)
						buildBottomSheetBarButton(AppColors.mainBackgroundColor, Icons.close, AppLocales.of(context).translate('actions.deselectAll'), onSelectAll)
					else
						buildBottomSheetBarButton(AppColors.mainBackgroundColor, Icons.playlist_add_check, AppLocales.of(context).translate('actions.selectAll'), onSelectAll),
				*/		
				buildBottomSheetBarButton(Colors.green, Icons.done, AppLocales.of(context).translate('actions.confirm'), () => { Navigator.pop(context) }),
			]
		);
	}

	Widget buildRepeatabilityTypeField(BuildContext context) {
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
			padding: EdgeInsets.zero,
			modalType: SmartSelectModalType.bottomSheet,
			leading: Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.refresh)),
			onChange: (val) => setState(() => widget.plan.repeatability = val)
		);
	}

	Widget buildRecurringFields(BuildContext context) {
		bool isWeekly = widget.plan.repeatabilityRage == PlanFormRepeatabilityRage.weekly;
		List<int> dayList = List<int>.generate(isWeekly ? 7 : 31, (i) => i + 1);

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
					padding: EdgeInsets.zero,
					modalType: SmartSelectModalType.bottomSheet,
					leading: Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.event)),
					onChange: (val) => setState(() => widget.plan.repeatabilityRage = val),
				),
				SmartSelect<int>.multiple(
					title: AppLocales.of(context).translate('$_pageKey.days.label${isWeekly ? 'Weekly' : 'Monthly'}'),
					placeholder: AppLocales.of(context).translate('$_pageKey.days.hint'),
					value: widget.plan.days,
					options: SmartSelectOption.listFrom<int, int>(
						source: dayList,
						value: (index, item) => item,
						title: (index, item) => isWeekly ? AppLocales.of(context).translate('date.weekday', {'WEEKDAY': item.toString()}) : item.toString()
					),
					isTwoLine: true,
					padding: EdgeInsets.zero,
					choiceType: SmartSelectChoiceType.chips,
					modalType: SmartSelectModalType.bottomSheet,
					modalConfig: SmartSelectModalConfig(
						trailing: buildBottomSheetBar(context, true, dayList, widget.plan.days)
					),
					leading: Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.date_range)),
					onChange: (val) => setState(() => { widget.plan.days = val })
				),
				Divider(),
				buildDateRangeFields(context)
			],
		);
	}

	Widget buildOneDayOnlyFields(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 8.0),
			child: DatePickerField(
				labelText: AppLocales.of(context).translate('$_pageKey.onlyOneDate.label'),
				errorText: AppLocales.of(context).translate('$_pageKey.onlyOneDate.emptyError'),
				dateController: _dateOneDayOnlyContoller, 
				dateField: widget.plan.onlyOnceDate, 
				callback: setDateCallback,
				canBeEmpty: false
			)
		);
	}

	Widget buildUntilCompletedFields(BuildContext context) {
		return buildDateRangeFields(context);
	}

	Widget buildDateRangeFields(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				Padding(
					padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
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
						rangeToDate: widget.plan.rangeToDate,
						dateController: _dateRageFromContoller, 
						dateField: widget.plan.rangeFromDate, 
						callback: setDateCallback
					)
				),
				Padding(
					padding: EdgeInsets.only(top: 8.0),
					child: DatePickerField(
						icon: Icons.event_note,
						labelText: AppLocales.of(context).translate('$_pageKey.range.toLabel'),
						helperText: AppLocales.of(context).translate('$_pageKey.range.hint'),
						rangeFromDate: widget.plan.rangeFromDate,
						dateController: _dateRageToContoller, 
						dateField: widget.plan.rangeToDate, 
						callback: setDateCallback
					)
				),
				Padding(
					padding: EdgeInsets.only(top: 12.0),
					child: SwitchListTile(
						value: widget.plan.isActive,
						contentPadding: EdgeInsets.zero,
						title: Text(AppLocales.of(context).translate('$_pageKey.active.label')),
						subtitle: Text(AppLocales.of(context).translate('$_pageKey.active.${widget.plan.isActive ? 'hintOn' : 'hintOff'}')),
						secondary: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.lightbulb_outline)),
						onChanged: (val) => setState(() => widget.plan.isActive = val)
					)
				),
			]
		);
	}

}
