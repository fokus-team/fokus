import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/navigation/task_form_params.dart';
import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/form_config.dart';
import 'package:fokus/utils/ui/reorderable_list.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/buttons/back_icon_button.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/forms/pointpicker_field.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';

class TaskFormPage extends StatefulWidget {
	final TaskFormParams params;

	TaskFormPage(this.params);

	@override
	_TaskFormPageState createState() => new _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
	static const String _pageKeyTaskForm = 'page.caregiverSection.taskForm';
	static const String _pageKeyPlanForm = 'page.caregiverSection.planForm';

	late GlobalKey<FormState> taskFormKey;
	bool isDataChanged = false;
	late TaskFormModel task;
	int maxSubtasks = 10;
	List<MapEntry<Key, String>> subtasksKeys = [];
	bool inReorder = false;


	TextEditingController _titleController = TextEditingController();
	TextEditingController _descriptionController = TextEditingController();
	TextEditingController _pointsController = TextEditingController();
	TextEditingController _subtasksController = TextEditingController();

	Duration dragDelayDuration = Duration(milliseconds: 600);
	Duration defaultSwitchDuration = Duration(milliseconds: 400);

	bool formModeIsCreate() => widget.params.task == null;

	@override
	void initState() {
		taskFormKey = GlobalKey<FormState>();
		task = TaskFormModel(
				key: ValueKey(DateTime.now().toString()),
				pointCurrency: UICurrency(type: CurrencyType.diamond)
		);

		if (!formModeIsCreate())
			task.copy(widget.params.task!);

		if (widget.params.task != null) {
			_titleController.text = widget.params.task!.title!;
			_descriptionController.text = widget.params.task!.description!;
			_pointsController.text =
			widget.params.task!.pointsValue != null ? widget.params.task!.pointsValue
					.toString() : '';
			if (widget.params.task!.subtasks != null)
				for (var subtask in widget.params.task!.subtasks!)
					subtasksKeys.add(
							MapEntry(ValueKey(DateTime.now().toString()), subtask));
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
				onWillPop: () async {
					bool? ret = await showExitFormDialog(context, true, isDataChanged);
					if (ret == null || !ret)
						return false;
					else
						return true;
				},
				child: Scaffold(
						body: Stack(
								children: [
									Positioned.fill(
											bottom: AppBoxProperties.standardBottomNavHeight,
											child: Form(
													key: taskFormKey,
													child: Material(
															child: Column(
																	children: [
																		buildCustomHeader(),
																		Expanded(child: buildFormFields())
																	]
															)
													)
											)
									),
									Positioned.fill(
											top: null,
											child: buildBottomNavigation()
									)
								]
						)
				)
		);
	}

	void showDeleteTaskDialog() {
		showBasicDialog(
				context,
				GeneralDialog.confirm(
						title: AppLocales.of(context).translate(
								'$_pageKeyTaskForm.removeTaskTitle'),
						content: AppLocales.of(context).translate(
								'$_pageKeyTaskForm.removeTaskText'),
						confirmColor: Colors.red,
						confirmText: '$_pageKeyTaskForm.removeTaskTitle',
						confirmAction: () {
							Future.wait([
								Future(widget.params.removeTaskCallback!())
							]);
							Navigator.of(context).pop();
							Navigator.of(context).pop();
						}
				)
		);
	}

	void saveTask() {
		if (taskFormKey.currentState!.validate()) {
			task.subtasks = subtasksKeys.map((e) => e.value).toList();
			if (formModeIsCreate())
				Future.wait([
					Future(widget.params.createTaskCallback!(task))
				]);
			else
				Future.wait([
					Future(widget.params.saveTaskCallback!(task))
				]);
			Navigator.of(context).pop();
		}
	}

	Widget buildCustomHeader() {
		bool hasTitle = !formModeIsCreate() && task.title != null &&
				task.title!.length > 0;
		double appBarVerticalPadding = hasTitle ? 8.0 : 12.0;
		return Material(
				elevation: 4.0,
				color: AppColors.formColor,
				child: Container(
						child: SafeArea(
								child: ListTile(
										dense: true,
										contentPadding: EdgeInsets.symmetric(
												vertical: 0.0, horizontal: 4.0),
										trailing: HelpIconButton(helpPage: 'task_creation'),
										leading: BackIconButton(exitCallback: () =>
												showExitFormDialog(context, false, isDataChanged)),
										title: Padding(
												padding: EdgeInsets.only(top: appBarVerticalPadding,
														bottom: appBarVerticalPadding,
														left: 4.0),
												child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: <Widget>[
															AnimatedDefaultTextStyle(
																	duration: Duration(milliseconds: 200),
																	child: Text(AppLocales.of(context).translate(
																			'$_pageKeyPlanForm.${formModeIsCreate()
																					? 'addTaskButton'
																					: 'editTaskButton'}')),
																	style: hasTitle ?
																	Theme
																			.of(context)
																			.textTheme
																			.bodyText1! :
																	Theme
																			.of(context)
																			.textTheme
																			.headline3!
																			.copyWith(
																			color: Colors.white, fontSize: 20.0)
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
																			tag: formModeIsCreate()
																					? "none3463634634"
																					: widget.params.task!.key,
																			child: Text(
																					task.title!,
																					style: Theme
																							.of(context)
																							.textTheme
																							.headline2
																							?.copyWith(color: Colors.white),
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

	Widget buildBottomNavigation() {
		return Container(
				padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
				decoration: AppBoxProperties.elevatedContainer,
				height: AppBoxProperties.standardBottomNavHeight,
				child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						crossAxisAlignment: CrossAxisAlignment.end,
						children: <Widget>[
							!formModeIsCreate() ?
							FlatButton(
									onPressed: () => showDeleteTaskDialog(),
									textColor: Colors.red,
									child: Row(
											children: <Widget>[
												Icon(Icons.close),
												Text(AppLocales.of(context).translate(
														'$_pageKeyPlanForm.removeTaskButton'))
											]
									)
							)
									: SizedBox.shrink(),
							FlatButton(
									onPressed: () => saveTask(),
									child: Row(
											children: <Widget>[
												Hero(
														tag: formModeIsCreate()
																? "newTaskDialog"
																: "none12345235",
														child: Text(
																AppLocales.of(context).translate(
																		'$_pageKeyPlanForm.${formModeIsCreate()
																				? 'addTaskButton'
																				: 'saveTaskButton'}'),
																style: Theme
																		.of(context)
																		.textTheme
																		.button
																		?.copyWith(
																		color: AppColors.mainBackgroundColor)
														)
												)
											]
									)
							)
						]
				)
		);
	}

	Widget buildFormFields() {
		return ListView(
				physics: inReorder
						? NeverScrollableScrollPhysics()
						: BouncingScrollPhysics(),
				shrinkWrap: true,
				children: <Widget>[
					buildNameField(),
					buildDescriptionField(),
					buildSubtasksFields(),
					Divider(),
					SizedBox(height: 16.0),
					getPointsFields(currencies: widget.params.currencies),
					buildTimerField(),
					Divider(),
					buildOptionalField(),
					if(!formModeIsCreate())
						SizedBox(height: 32.0)
				]
		);
	}

	Widget buildNameField() {
		return Padding(
				padding: EdgeInsets.only(
						top: 0.0, bottom: 6.0, left: 20.0, right: 20.0),
				child: TextFormField(
						autofocus: formModeIsCreate(),
						controller: _titleController,
						decoration: AppFormProperties.textFieldDecoration(Icons.edit)
								.copyWith(
								labelText: AppLocales.of(context).translate(
										'$_pageKeyTaskForm.fields.taskName.label')
						),
						maxLength: AppFormProperties.textFieldMaxLength,
						textCapitalization: TextCapitalization.sentences,
						validator: (value) {
							return value!.trim().isEmpty ? AppLocales.of(context).translate(
									'alert.genericEmptyValue') : null;
						},
						onChanged: (val) =>
								setState(() {
									isDataChanged = task.title != val;
									task.title = val;
								})
				)
		);
	}

	Widget buildDescriptionField() {
		return Padding(
				padding: EdgeInsets.only(
						top: 5.0, bottom: 6.0, left: 20.0, right: 20.0),
				child: TextFormField(
					controller: _descriptionController,
					decoration: AppFormProperties.longTextFieldDecoration(
							Icons.description).copyWith(
							labelText: AppLocales.of(context).translate(
									'$_pageKeyTaskForm.fields.taskDescription.label')
					),
					maxLength: AppFormProperties.longTextFieldMaxLength,
					minLines: AppFormProperties.longTextMinLines,
					maxLines: AppFormProperties.longTextMaxLines,
					textCapitalization: TextCapitalization.sentences,
					onChanged: (val) =>
							setState(() {
								isDataChanged = task.description != val;
								task.description = val;
							}),
				)
		);
	}

	Widget buildSubtasksFields() {
		return Column(
			children: [
				buildReorderableList<MapEntry<Key, String>>(
						child: (item) =>
								Handle(
										vibrate: true,
										delay: dragDelayDuration,
										child: _getSubtaskCard(item)
								),
						items: subtasksKeys,
						getKey: (item) => item.key,
						onReorderStarted: (item, index) => setState(() => inReorder = true),
						onReorderFinished: (item, from, to, newItems) {
							setState(() {
								subtasksKeys
									..clear()
									..addAll(newItems);
								inReorder = false;
								isDataChanged = true;
							});
						},
						header: AnimatedSwitcher(
								duration: defaultSwitchDuration,
								child: subtasksKeys.isNotEmpty ?
								Padding(
									padding: const EdgeInsets.only(right: 4.0),
									child: ListTile(
										leading: Padding(padding: EdgeInsets.all(8.0),
												child: Icon(Icons.playlist_add_check)),
										title: Text(AppLocales.of(context).translate(
												'$_pageKeyTaskForm.fields.subtaskDescription.sectionTitle')),
										subtitle: Text(AppLocales.of(context).translate(
												'$_pageKeyTaskForm.fields.subtaskDescription.sectionSubtitle',
												{'NUM_SUBTASKS': subtasksKeys.length})),
									),
								) : SizedBox.shrink()
						)
				),
				if (subtasksKeys.length < maxSubtasks)
					_getSubtaskFormField()
			],
		);
	}

	Widget getPointsFields(
			{List<UICurrency> currencies = const [], bool loading = false}) {
		return PointPickerField(
			controller: _pointsController,
			pickedCurrency: task.pointCurrency,
			currencies: currencies,
			loading: loading,
			labelValueText: AppLocales.of(context).translate(
					'$_pageKeyTaskForm.fields.taskPoints.valueLabel'),
			helperValueText: AppLocales.of(context).translate(
					'$_pageKeyTaskForm.fields.taskPoints.hint'),
			labelCurrencyText: AppLocales.of(context).translate(
					'$_pageKeyTaskForm.fields.taskPoints.currencyLabel'),
			pointValueSetter: (String? val) {
				setState(() {
					if (val == null || int.tryParse(val) == 0) {
						isDataChanged = task.pointsValue == null;
						task.pointsValue = null;
						return;
					}
					isDataChanged = task.pointsValue != int.tryParse(val);
					task.pointsValue = int.tryParse(val);
				});
			},
			pointCurrencySetter: (val) {
				setState(() {
					isDataChanged = task.pointCurrency != val;
					task.pointCurrency = val;
				});
			},
		);
	}

	Widget buildTimerField() {
		return Padding(
				padding: EdgeInsets.only(top: 12.0),
				child: ListTile(
						contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
						leading: Padding(
								padding: EdgeInsets.all(8.0), child: Icon(Icons.timer)),
						title: Text(AppLocales.of(context).translate(
								'$_pageKeyTaskForm.fields.taskTimer.label')),
						subtitle: (task.timer == 0) ?
						Text(AppLocales.of(context).translate(
								'$_pageKeyTaskForm.fields.taskTimer.notSet'))
								: Text(AppLocales.of(context).translate(
								'$_pageKeyTaskForm.fields.taskTimer.set') + ' '
								+ AppLocales.of(context).translate(
										'$_pageKeyTaskForm.fields.taskTimer.format', {
									'HOURS_NUM': (task.timer! ~/ 60).toString(),
									'MINUTES_NUM': (task.timer! % 60).toString()
								})),
						trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
						onTap: () {
							FocusManager.instance.primaryFocus?.unfocus();
							showTimerPickerDialog();
						}
				)
		);
	}

	void showTimerPickerDialog() {
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
				selecteds: [task.timer! ~/ 60, task.timer! % 60],
				itemExtent: 40.0,
				height: 120.0,
				looping: true,
				hideHeader: true,
				title: Text(AppLocales.of(context).translate(
						'$_pageKeyTaskForm.fields.taskTimer.label')),
				onConfirm: (Picker picker, List value) {
					var times = picker.getSelectedValues();
					var timeInMinutes = times[0] * 60 + times[1];
					setState(() => task.timer = timeInMinutes);
				},
				confirmText: AppLocales.of(context).translate('actions.confirm'),
				onCancel: () => {},
				cancel: Wrap(
						spacing: 6.0,
						children: <Widget>[
							FlatButton(
									textColor: Colors.red,
									child: Text(
											AppLocales.of(context).translate('actions.clear')),
									onPressed: () {
										setState(() => task.timer = 0);
										Navigator.of(context).pop();
									}
							),
							FlatButton(
									child: Text(
											AppLocales.of(context).translate('actions.cancel')),
									onPressed: () {
										Navigator.of(context).pop();
									}
							)
						]
				),
				footer: SizedBox.shrink()
		).showDialog(context);
	}

	Widget buildOptionalField() {
		return Padding(
				padding: EdgeInsets.only(top: 12.0),
				child: SwitchListTile(
						value: task.optional!,
						title: Text(AppLocales.of(context).translate(
								'$_pageKeyTaskForm.fields.taskOptional.label')),
						subtitle: Text(AppLocales.of(context).translate(
								'$_pageKeyTaskForm.fields.taskOptional.hint')),
						secondary: Padding(
								padding: EdgeInsets.all(8.0), child: Icon(Icons.unfold_more)),
						onChanged: (val) => setState(() => task.optional = val)
				)
		);
	}


	Widget _getSubtaskFormField() {
		return Padding(
			padding: EdgeInsets.only(
					top: 20.0, bottom: 12.0, left: 20.0, right: 20.0),
			child: Row(
				children: [
					Expanded(
						child: TextFormField(controller: _subtasksController,
							decoration: AppFormProperties.textFieldDecoration(
									Icons.playlist_add).copyWith(
								labelText: AppLocales.of(context).translate(
										'$_pageKeyTaskForm.fields.subtaskDescription.label'),
							),
							maxLength: AppFormProperties.textFieldMaxLength,
							textCapitalization: TextCapitalization.sentences,
							onChanged: (val) => setState(() => isDataChanged = true),
						),
					),
					Padding(
						padding: EdgeInsets.only(right: 24, bottom: 24),
						child: Tooltip(
								message: AppLocales.of(context).translate(
										'$_pageKeyTaskForm.fields.subtaskDescription.add'),
								child: Padding(
										padding: EdgeInsets.only(left: 8.0),
										child: AnimatedSwitcher(
											duration: defaultSwitchDuration,
											child: MaterialButton(
													visualDensity: VisualDensity.compact,
													materialTapTargetSize: MaterialTapTargetSize
															.shrinkWrap,
													child: Icon(Icons.add, color: Colors.white, size: 30),
													color: AppColors.caregiverButtonColor,
													onPressed: _subtasksController.text == ""
															? null
															: () {
														if (_subtasksController.text != "")
															setState(() {
																subtasksKeys.add(MapEntry(
																		ValueKey(DateTime.now().toString()),
																		_subtasksController.text));
																isDataChanged = true;
																_subtasksController.text = "";
															});
													},
													disabledColor: Theme
															.of(context)
															.dividerColor,
													padding: EdgeInsets.all(12.0),
													shape: CircleBorder(),
													minWidth: 0
											),
										)
								)
						),
					)
				],
			),
		);
	}

	Widget _getSubtaskCard(MapEntry<Key, String> subtask) {
		return Padding(
			padding: EdgeInsets.only(left: 64, right: 16),
			child: IntrinsicHeight(
				child: Card(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(
							AppBoxProperties.roundedCornersRadius)),
					child: InkWell(
						splashColor: Colors.blueGrey[50],
						highlightColor: Colors.blueGrey[50],
						onTap: () => {},
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											Padding(
												padding: const EdgeInsets.symmetric(
														horizontal: 12.0, vertical: 8),
												child: Text(
													subtask.value,
													style: Theme
															.of(context)
															.textTheme
															.subtitle1,
													overflow: TextOverflow.ellipsis,
													maxLines: 6,
												),
											),
										],
									),
								),
								IconButton(
									icon: Icon(Icons.delete, size: 24, color: Colors.grey),
									onPressed: () {
										setState(() {
											subtasksKeys.remove(subtask);
											isDataChanged = true;
										});
									},
								)
							],
						),
					),
				),
			),
		);
	}
}