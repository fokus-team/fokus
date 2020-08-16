import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_select/smart_select.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/plan/ui_task.dart';
import 'package:fokus/model/ui/plan/ui_plan_currency.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/buttons/back_icon_button.dart';

class TaskForm extends StatefulWidget {
	final UITask task;
	final Function createTaskCallback;
	final Function removeTaskCallback;
	final Function saveTaskCallback;

	TaskForm({
		@required this.task,
		this.createTaskCallback,
		this.removeTaskCallback,
		this.saveTaskCallback
	});

	@override
	_TaskFormState createState() => new _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
	static const String _pageKeyTaskForm = 'page.caregiverSection.taskForm';
	static const String _pageKeyPlanForm = 'page.caregiverSection.planForm';
	double bottomBarHeight = 60.0;

	GlobalKey<FormState> taskFormKey;
	bool isDataChanged = false;
	UITask task;

	List<UIPlanCurrency> currencies = [
		UIPlanCurrency(id: Mongo.ObjectId.fromHexString('5f9997f18c7472942f9979a3'), type: CurrencyType.diamond, title: "Punkty"),
		UIPlanCurrency(id: Mongo.ObjectId.fromHexString('5f9997f18c7472942f9979a2'), type: CurrencyType.ruby, title: "Klejnoty"),
		UIPlanCurrency(id: Mongo.ObjectId.fromHexString('5f9997f18c7472942f9979a1'), type: CurrencyType.amethyst, title: "Super punkty")
	]; // TODO Load currencies list from user

	TextEditingController _titleController = TextEditingController();
	TextEditingController _descriptionController = TextEditingController();
	TextEditingController _pointsController = TextEditingController();

	bool formModeIsCreate() => widget.task == null;

	@override
  void initState() {
		taskFormKey = GlobalKey<FormState>();
		task = UITask(
			key: ValueKey(DateTime.now().toString()),
			pointCurrency: currencies[0]
		);

		if(!formModeIsCreate())
			task.copy(widget.task);

		if(widget.task != null) {
			_titleController.text = widget.task.title;
			_descriptionController.text = widget.task.description;
			_pointsController.text = widget.task.pointsValue != null ? widget.task.pointsValue.toString() : null;
		}
    super.initState();
  }
	
	@override
  void dispose() {
		_titleController.dispose();
		_descriptionController.dispose();
		_pointsController.dispose();
		super.dispose();
	}

  @override
  Widget build(BuildContext context) {
		return WillPopScope(
			onWillPop: () => exitForm(context, true),
			child: Scaffold(
				body: Stack(
					children: [
						Positioned.fill(
							bottom: bottomBarHeight,
							child: Form(
								key: taskFormKey,
								child: Material(
									child: Column(
										children:[ 
											buildCustomHeader(context),
											Expanded(child: buildFormFields(context))
										]
									)
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

	void showDeleteTaskDialog(BuildContext context) {
		showBasicDialog(
			context,
			GeneralDialog.confirm(
				title: AppLocales.of(context).translate('$_pageKeyTaskForm.removeTaskTitle'),
				content: AppLocales.of(context).translate('$_pageKeyTaskForm.removeTaskText'),
				confirmColor: Colors.red,
				confirmText: '$_pageKeyTaskForm.removeTaskTitle',
				confirmAction: () {
					Future.wait([
						Future(widget.removeTaskCallback())
					]);
					Navigator.of(context).pop();
					Navigator.of(context).pop();
				}
			)
		);
	}

	void saveTask(BuildContext context) {
		if(taskFormKey.currentState.validate()) {
			if(formModeIsCreate())
				Future.wait([
					Future(widget.createTaskCallback(task))
				]);
			else
				Future.wait([
					Future(widget.saveTaskCallback(task))
				]);
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

	Widget buildCustomHeader(BuildContext context) {
		bool hasTitle = !formModeIsCreate() && task.title != null && task.title.length > 0;
		double appBarVerticalPadding = hasTitle ? 8.0 : 12.0;
		return Material(
			elevation: 4.0,
			color: AppColors.formColor,
			child: Container(
				child: SafeArea(
					child: ListTile(
						dense: true,
						contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
						trailing: HelpIconButton(helpPage: 'task_creation'),
						leading: BackIconButton(),
						title: Padding(
							padding: EdgeInsets.only(top: appBarVerticalPadding, bottom: appBarVerticalPadding, left: 4.0),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									AnimatedDefaultTextStyle(
										duration: Duration(milliseconds: 200),
										child: Text(AppLocales.of(context).translate('$_pageKeyPlanForm.${formModeIsCreate() ? 'addTaskButton' : 'editTaskButton'}')), 
										style: hasTitle ?
											Theme.of(context).textTheme.bodyText1 :
											Theme.of(context).textTheme.headline3.copyWith(color: Colors.white, fontSize: 20.0)
									),
									AnimatedSwitcher(
										duration: Duration(milliseconds: 400),
										transitionBuilder: (child, animation) {
											return SizeTransition(
												sizeFactor: animation,
												axisAlignment: 1,
												axis: Axis.vertical,
												child: child
											);
										},
										child: hasTitle ?
											Hero(
												tag: formModeIsCreate() ? "none3463634634" : widget.task.key,
												child: Text(
													task.title,
													style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white),
													overflow: TextOverflow.fade,
													softWrap: false,
													maxLines: 1
												)
											)
											: SizedBox.shrink()
									)
								]
							)
						)
					)
				)
			)
		);
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
					!formModeIsCreate() ?
						FlatButton(
							onPressed: () => showDeleteTaskDialog(context),
							textColor: Colors.red,
							child: Row(
								children: <Widget>[
									Icon(Icons.close),
									Text(AppLocales.of(context).translate('$_pageKeyPlanForm.removeTaskButton'))
								]
							)
						)
						: SizedBox.shrink(),
					FlatButton(
						onPressed: () => saveTask(context),
						child: Row(
							children: <Widget>[
								Hero(
									tag: formModeIsCreate() ? "newTaskDialog" : "none12345235",
									child: Text(
										AppLocales.of(context).translate('$_pageKeyPlanForm.${formModeIsCreate() ? 'addTaskButton' : 'saveTaskButton'}'),
										style: Theme.of(context).textTheme.button.copyWith(color: AppColors.mainBackgroundColor)
									)
								)
							]
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
				buildDescriptionField(context),
				buildPointsFields(context),
				buildTimerField(context),
				Divider(),
				buildOptionalField(context),
				if(!formModeIsCreate())
					SizedBox(height: 32.0) 
			]
		);
	}

	Widget buildNameField(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 0.0, bottom: 6.0, left: 20.0, right: 20.0),
			child: TextFormField(
				autofocus: formModeIsCreate(),
				controller: _titleController,
				decoration: InputDecoration(
					icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.edit)),
					contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
					border: OutlineInputBorder(),
					labelText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskName.label')
				),
				maxLength: 120,
				textCapitalization: TextCapitalization.sentences,
				validator: (value) {
					return value.trim().isEmpty ? AppLocales.of(context).translate('alert.genericEmptyValue') : null;
				},
				onChanged: (val) => setState(() {
					task.title = val;
					isDataChanged = task.title != widget.task.title;
				})
			)
		);
	}

	Widget buildDescriptionField(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 5.0, bottom: 6.0, left: 20.0, right: 20.0),
			child: TextFormField(
				controller: _descriptionController,
				decoration: InputDecoration(
					icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.description)),
					contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
					border: OutlineInputBorder(),
					labelText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskDescription.label'),
					alignLabelWithHint: true
				),
				maxLength: 1000,
				maxLines: 6,
				minLines: 4,
				textCapitalization: TextCapitalization.sentences,
				onChanged: (val) => setState(() {
					task.description = val;
					isDataChanged = task.description != widget.task.description;
				})
			)
		);
	}
	
	Widget buildPointsFields(BuildContext context) {
		return SmartSelect<UIPlanCurrency>.single(
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
										helperText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskPoints.hint'),
										labelText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskPoints.valueLabel'),
										suffixIcon: IconButton(
											onPressed: () {
												FocusScope.of(context).requestFocus(FocusNode());
												_pointsController.clear();
												task.pointsValue = null;
											},
											icon: Icon(Icons.clear)
										)
									),
									validator: (value) {
										final range = [0, 1000000];
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
										task.pointsValue = int.tryParse(val);
										isDataChanged = task.pointsValue != widget.task.pointsValue;
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
									message: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskPoints.currencyLabel'),
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
			title: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskPoints.currencyLabel'),
			value: task.pointCurrency,
			options: [
				for(UIPlanCurrency element in currencies)
					SmartSelectOption(
						title: element.title,
						value: element
					)
			],
			choiceConfig: SmartSelectChoiceConfig(
				builder: (item, checked, onChange) {
					return RadioListTile<UIPlanCurrency>(
						value: item.value,
						groupValue: task.pointCurrency,
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
			modalType: SmartSelectModalType.popupDialog,
			onChange: (val) => setState(() => task.pointCurrency = val)
		);
	}

	Widget buildTimerField(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 12.0),
			child: ListTile(
				contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
				leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.timer)),
				title: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.label')),
				subtitle: (task.timer == 0) ?
					Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.notSet'))
					: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.set') + ' ' 
						+ AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.format', {
						'HOURS_NUM': (task.timer ~/ 60).toString(),
						'MINUTES_NUM': (task.timer % 60).toString()
					})),
				trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
				onTap: () {
					FocusManager.instance.primaryFocus.unfocus();
					showTimerPickerDialog(context);
				}
			)
		);
	}

	void showTimerPickerDialog(BuildContext context) {
		Picker(
			adapter: NumberPickerAdapter(data: [
				NumberPickerColumn(
					begin: 0, 
					end: 23, 
					suffix: Padding(
						padding: EdgeInsets.only(left: 4.0, top: 4.0),
						child: Text(
							AppLocales.of(context).translate('hour'),
							style: TextStyle(fontSize: 15.0, color: Colors.grey)
						)
					)
				),
				NumberPickerColumn(
					begin: 0,
					end: 59,
					suffix: Padding(
						padding: EdgeInsets.only(left: 4.0, top: 2.0),
						child: Text(
							AppLocales.of(context).translate('minute'),
							style: TextStyle(fontSize: 15.0, color: Colors.grey)
						)
					)
				)
			]),
			selecteds: [task.timer ~/ 60, task.timer % 60],
			itemExtent: 40.0,
			height: 120.0,
			looping: true,
			hideHeader: true,
			title: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.label')),
			onConfirm: (Picker picker, List value) {
				var times = picker.getSelectedValues();
				var timeInMinutes = times[0]*60 + times[1];
				setState(() => task.timer = timeInMinutes);
			},
			confirmText: AppLocales.of(context).translate('actions.confirm'),
			onCancel: () => {},
			cancel: Wrap(
				spacing: 6.0,
				children: <Widget>[
					FlatButton(
						textColor: Colors.red,
						child: Text(AppLocales.of(context).translate('actions.clear')),
						onPressed: () {
							setState(() => task.timer = 0);
							Navigator.of(context).pop();
						}
					),
					FlatButton(
						child: Text(AppLocales.of(context).translate('actions.cancel')),
						onPressed: () {
							Navigator.of(context).pop();
						}
					)
				]
			),
			footer: SizedBox.shrink()
		).showDialog(context);
	}

	Widget buildOptionalField(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 12.0),
			child: SwitchListTile(
				value: task.optional,
				title: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskOptional.label')),
				subtitle: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskOptional.hint')),
				secondary: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.unfold_more)),
				onChanged: (val) => setState(() => task.optional = val)
			)
		);
	}

}
