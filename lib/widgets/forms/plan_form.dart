import 'package:flutter/material.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:smart_select/smart_select.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/model/ui/plan/ui_plan_form.dart';
import 'package:fokus/model/ui/user/ui_child.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/widgets/forms/datepicker_field.dart';
import 'package:fokus/widgets/cards/item_card.dart';

class PlanForm extends StatefulWidget {
	final UIPlanForm plan;
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

	double bottomBarHeight = 60.0;

	TextEditingController _planNameContoller = TextEditingController();
	TextEditingController _dateOneDayOnlyContoller = TextEditingController();
	TextEditingController _dateRageFromContoller = TextEditingController();
	TextEditingController _dateRageToContoller = TextEditingController();

	List<UIChild> children = [
		UIChild(Mongo.ObjectId.fromHexString('5f9997f18c7472942f9979a8'), "Mateusz", avatar: 5),
		UIChild(Mongo.ObjectId.fromHexString('f1068d375fe7b2e20ea84512'), "Gosia", avatar: 23),
		UIChild(Mongo.ObjectId.fromHexString('72af61d19e589bad8d0fc5c5'), "Andżelika", avatar: 21),
		UIChild(Mongo.ObjectId.fromHexString('a5b458256654875d95d19210'), "Joanna", avatar: 24)
	]; // TODO Load children list from user

	String getOnlyDatePart(DateTime date) => date != null ? date.toLocal().toString().split(' ')[0] : '';

	void setDateCallback(DateTime pickedDate, Function dateSetter, TextEditingController dateContoller) {
		setState(() {
			dateSetter(pickedDate);
			dateContoller.value = TextEditingValue(text: getOnlyDatePart(pickedDate));
		});
	}
	
  @override
	void initState() {
		_planNameContoller.text = widget.plan.name ?? '';
		_dateOneDayOnlyContoller.text = widget.plan.onlyOnceDate != null ? getOnlyDatePart(widget.plan.onlyOnceDate) : '';
		_dateRageFromContoller.text = widget.plan.rangeDate.from != null ? getOnlyDatePart(widget.plan.rangeDate.from) : '';
		_dateRageToContoller.text = widget.plan.rangeDate.to != null ? getOnlyDatePart(widget.plan.rangeDate.to) : '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
			children: [
				Positioned.fill(
					bottom: bottomBarHeight,
					child: ListView(
						shrinkWrap: true,
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
					)
				),
				Positioned.fill(
					top: null,
					child: buildBottomNavigation(context)
				)
			]
		);
  }

	Widget buildPlanNameField(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 25.0, bottom: 10.0, left: 20.0, right: 20.0),
			child: TextFormField(
				controller: _planNameContoller,
				decoration: InputDecoration(
					icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.description)),
					contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
					border: OutlineInputBorder(),
					labelText: AppLocales.of(context).translate('$_pageKey.planName.label')
				),
				maxLength: 120,
				textCapitalization: TextCapitalization.sentences,
				validator: (value) {
					return value.trim().isEmpty ? AppLocales.of(context).translate('$_pageKey.planName.emptyError') : null;
				},
				onChanged: (val) => setState(() => widget.plan.name = val)
			)
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
			leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.people)),
			onChange: (val) => setState(() {
				FocusManager.instance.primaryFocus.unfocus();
				widget.plan.children.clear();
				widget.plan.children = val;
			})
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
			modalType: SmartSelectModalType.bottomSheet,
			leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.refresh)),
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
					modalType: SmartSelectModalType.bottomSheet,
					leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.event)),
					onChange: (val) => setState(() {
						widget.plan.repeatabilityRage = val;
						widget.plan.days.clear();
					}),
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
					choiceType: SmartSelectChoiceType.chips,
					modalType: SmartSelectModalType.bottomSheet,
					modalConfig: SmartSelectModalConfig(
						trailing: buildBottomSheetBar(context, true, dayList, widget.plan.days)
					),
					leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.date_range)),
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
				dateSetter: widget.plan.setOnlyOnceDate, 
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
						dateController: _dateRageFromContoller, 
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
						dateController: _dateRageToContoller, 
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

	Widget buildBottomNavigation(BuildContext context) {
		return Container(
			height: bottomBarHeight,
			child: Stack(
				children: [
					Positioned(
						bottom: 0,
						left: 0,
						right: 0,
						child: Container(
							padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
							decoration: AppBoxProperties.elevatedContainer,
							height: bottomBarHeight,
							child: Row(
								mainAxisAlignment: MainAxisAlignment.end,
								crossAxisAlignment: CrossAxisAlignment.end,
								children: <Widget>[
									FlatButton(
										onPressed: () => widget.goNextCallback(),
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
