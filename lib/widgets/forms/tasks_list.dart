import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';

import 'package:fokus/model/ui/plan/ui_task_form.dart';
import 'package:fokus/model/ui/plan/ui_plan_form.dart';

import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/utils/app_locales.dart';

import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/forms/task_form.dart';

class TaskList extends StatefulWidget {
	final UIPlanForm plan;
	final Function goBackCallback;
	final Function submitCallback;
	final bool isCreateMode;

	TaskList({
		@required this.plan,
		@required this.goBackCallback,
		@required this.submitCallback,
		@required this.isCreateMode,
		Key key
	}) : super(key: key);

	@override
	TaskListState createState() => new TaskListState();
}

class TaskListState extends State<TaskList> with TickerProviderStateMixin {
	static const String _pageKey = 'page.caregiverSection.planForm';

	final int maxTaskCount = 20;

	Duration insertDuration = Duration(milliseconds: 800);
	Duration removeDuration = Duration(milliseconds: 800);
	Duration dragDuration = Duration(milliseconds: 200);
	Duration dragDelayDuration = Duration(milliseconds: 600);
	Duration defaultSwitchDuration = Duration(milliseconds: 400);

	double bottomBarHeight = 82.0;
	bool inReorder = false;

  @override
  Widget build(BuildContext context) {
		return Stack(
			children: [
				Positioned.fill(
					bottom: bottomBarHeight,
					child: ListView(
						physics: inReorder ? NeverScrollableScrollPhysics() : null,
						children: [
							buildReordableTaskList(context),
							buildOptionalTaskList(context),
							buildNoTasksAddedMessage(context),
							SizedBox(height: 32.0)
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

	void sortTasks() {
		setState(() {
			widget.plan.tasks.sort((a, b) {
				if (a.optional && !b.optional) 
					return 1;
				if (!a.optional && b.optional) 
					return -1;
				return 0;
			});
		});
	}

	void clearAllTasks() {
		showConfirmClearAllDialog(context, () {
			Future.wait([
				Future(() => setState(() {
					widget.plan.tasks.clear();
				}))
			]);
		});
	}

	void addNewTask() {
		Navigator.of(context).push(MaterialPageRoute(
			builder: (context) => TaskForm(
				task: null,
				createTaskCallback: (newTask) { 
					Future.wait([
						Future(() => setState(() {
							widget.plan.tasks.add(newTask);
							sortTasks();
						}))
					]);
				}
			)
		));
	}

	void editTask(UITaskForm task) {
		Navigator.of(context).push(MaterialPageRoute(
			builder: (context) => TaskForm(
				task: task,
				saveTaskCallback: (UITaskForm updatedTask) {
					Future.wait([
						Future(() => setState(() {
							task.copy(updatedTask);
							sortTasks();
						}))
					]);
				},
				removeTaskCallback: () {
					Future.wait([
						Future(() => setState(() {
							widget.plan.tasks.remove(task);
							sortTasks();
						}))
					]);
				}
			)
		));
	}

	void onReorderFinished(List<UITaskForm> newItems) {
    setState(() {
      inReorder = false;
			widget.plan.tasks..retainWhere((task) => task.optional == true)..addAll(newItems);
			sortTasks();
    });
  }

	Widget buildReordableTaskList(BuildContext context) {
		final requiredTasks = widget.plan.tasks.where((element) => element.optional == false);
		return ImplicitlyAnimatedReorderableList<UITaskForm>(
			shrinkWrap: true,
			physics: NeverScrollableScrollPhysics(),
			items: requiredTasks.toList(),
			areItemsTheSame: (a, b) => a.key == b.key,
			onReorderStarted: (_, __) => setState(() { inReorder = true; }),
			onReorderFinished: (item, from, to, newItems) => onReorderFinished(newItems),
			insertDuration: insertDuration,
			removeDuration: removeDuration,
			dragDuration: dragDuration,
			itemBuilder: (context, itemAnimation, item, index) {
				return Reorderable(
					key: item.key,
					builder: (context, dragAnimation, inDrag) {
						final color = Color.lerp(Colors.white, Colors.white.withOpacity(0.8), dragAnimation.value);
						final offsetAnimation = Tween<Offset>(begin: Offset(-2.0, 0.0), end: Offset(0.0, 0.0)).animate(CurvedAnimation(
							curve: Interval(0.6, 1, curve: Curves.easeOutCubic),
							parent: itemAnimation,
						));
						return SizeTransition(
							axis: Axis.vertical,
							sizeFactor: CurvedAnimation(
							curve: Interval(0, 0.5, curve: Curves.easeOutCubic),
								parent: itemAnimation,
							),
							child: SlideTransition(
								position: offsetAnimation,
								child: Transform.scale(
									scale: 1.0 + 0.05*dragAnimation.value,
									child: Container(
										margin: EdgeInsets.symmetric(horizontal: 16.0),
										child: Handle(
											vibrate: true,
											delay: dragDelayDuration,
											child: buildTaskCard(context, item, color, false)
										)
									)
								)
							) 
						);
					}
				);
			},
			header: AnimatedSwitcher(
				duration: defaultSwitchDuration,
				child: widget.plan.tasks.isNotEmpty ?
					buildTaskListHeader(context, AppLocales.of(context).translate('$_pageKey.requiredTaskListTitle'), requiredTasks.length)
					: SizedBox.shrink()
			)
		);
	}

	Widget buildOptionalTaskList(BuildContext context) {
		final optionalTasks = widget.plan.tasks.where((element) => element.optional == true);
		return Column(
			children: [
				AnimatedSwitcher(
					duration: defaultSwitchDuration,
					child: (optionalTasks.isNotEmpty) ?
						buildTaskListHeader(context, AppLocales.of(context).translate('$_pageKey.optionalTaskListTitle'), optionalTasks.length)
						: SizedBox.shrink()
				),
				ImplicitlyAnimatedList<UITaskForm>(
					shrinkWrap: true,
					physics: NeverScrollableScrollPhysics(),
					items: optionalTasks.toList(),
					areItemsTheSame: (a, b) => a.key == b.key,
					insertDuration: insertDuration,
					removeDuration: removeDuration,
					itemBuilder: (context, itemAnimation, item, index) {
						final offsetAnimation = Tween<Offset>(begin: Offset(-2.0, 0.0), end: Offset(0.0, 0.0)).animate(CurvedAnimation(
							curve: Interval(0.6, 1, curve: Curves.easeOutCubic),
							parent: itemAnimation,
						));
						return SizeTransition(
							axis: Axis.vertical,
							sizeFactor: CurvedAnimation(
							curve: Interval(0, 0.5, curve: Curves.easeOutCubic),
								parent: itemAnimation,
							),
							child: SlideTransition(
								position: offsetAnimation,
								child: Container(
									margin: EdgeInsets.symmetric(horizontal: 16.0),
									child: buildTaskCard(context, item, Colors.white, true)
								)
							) 
						);
					}
				)
			]
		);
	}

	Widget buildTaskListHeader(BuildContext context, String title, int count) {
		return Padding(
			padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0).copyWith(top: 20.0),
			child: Align(
				alignment: Alignment.centerLeft,
				child:Text(
					title + ' ($count)',
					style: TextStyle(fontWeight: FontWeight.bold)
				)
			)
		);
	}

	Widget buildNoTasksAddedMessage(BuildContext context) {
		return AnimatedSwitcher(
			duration: Duration(seconds: 2),
			reverseDuration: defaultSwitchDuration,
			transitionBuilder: (Widget child, Animation<double> animation) {
				CurvedAnimation delayedAnimation = CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn));
				return FadeTransition(child: child, opacity: delayedAnimation);
			},
			child: (widget.plan.tasks.isEmpty) ?
			Center(
				child: Padding(
					padding: EdgeInsets.only(top: 50.0),
					child: Column(
						children: <Widget>[
							Padding(
								padding: EdgeInsets.only(bottom: 10.0),
								child: Icon(
									Icons.local_florist,
									size: 65.0,
									color: Colors.grey[400]
								)
							),
							Text(
								AppLocales.of(context).translate('$_pageKey.noTasksMessage'), 
								style: TextStyle(
									fontSize: 16.0,
									color: Colors.grey[400]
								)
							)
						]
					)
				)
			)
			: SizedBox.shrink()
		);
	}

	Widget buildTaskCard(BuildContext context, UITaskForm task, Color color, bool optional) {
		int index = (widget.plan.tasks..where((element) => element.optional == optional)).indexOf(task);

		return Card(
			child: InkWell(
				onTap: () => editTask(task),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: <Widget>[
								Expanded(
									child: Material(
										type: MaterialType.transparency,
										child: Padding(
											padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
											child: Wrap(
												runSpacing: 2.0,
												spacing: 4.0,
												children: [
													AttributeChip.withIcon(
														content: optional ? null : '#${(index+1).toString()}',
														icon: optional ? Icons.bubble_chart : null,
														color: Colors.blueGrey
													),
													if(task.pointsValue != null && task.pointsValue != 0)
														AttributeChip.withCurrency(
															content: task.pointsValue.toString(),
															currencyType: task.pointCurrency.type
														),
													if(task.timer != null && task.timer != 0)
														AttributeChip.withIcon(
															content: AppLocales.of(context).translate('page.caregiverSection.taskForm.taskTimerFormat', {
																'HOURS_NUM': (task.timer ~/ 60).toString(),
																'MINUTES_NUM': (task.timer % 60).toString()
															}),
															icon: Icons.timer, 
															color: Colors.orange
														)
												]
											)
										)
									)
								),
								Padding(
									padding: EdgeInsets.all(8.0),
									child: Icon(Icons.call_made, color: Colors.grey)
								)
							]
						),
						Padding(
							padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 14.0).copyWith(bottom: 10.0),
							child: Hero(
								tag: task.key,
								child: Text(
									task.title,
									style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 17.0),
									maxLines: 3,
									overflow: TextOverflow.ellipsis
								)
							)
						)
					]
				)
			)
		);
	}

	void showConfirmClearAllDialog(BuildContext context, Function clearCallback) {
		showBasicDialog(
			context,
			GeneralDialog.confirm(
				title: AppLocales.of(context).translate('actions.clearAll'),
				content: AppLocales.of(context).translate('$_pageKey.clearAllTasksText'),
				confirmText: 'actions.clearAll',
				confirmColor: Colors.red,
				confirmAction: () {
					clearCallback();
					Navigator.of(context).pop();
				},
			) 
		);
	}

	Widget buildBottomNavigation(BuildContext context) {
		return Container(
			height: bottomBarHeight + 34.0,
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
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								crossAxisAlignment: CrossAxisAlignment.end,
								children: <Widget>[
									FlatButton(
										onPressed: () => widget.goBackCallback(),
										textColor: AppColors.mediumTextColor,
										child: Row(children: <Widget>[Icon(Icons.chevron_left), Text(AppLocales.of(context).translate('actions.back'))]),
									),
									FlatButton(
										onPressed: () => widget.submitCallback(),
										textColor: AppColors.mainBackgroundColor,
										child: Text(AppLocales.of(context).translate('$_pageKey.${widget.isCreateMode ? 'createPlanButton' : 'savePlanButton'}'))
									)
								]
							)
						)
					),
					Positioned(
						top: 0,
						left: 0,
						right: 0,
						child: buildFloatingButtons(context)
					)
				]
			)
		);
	}

	Widget buildFloatingButtons(BuildContext context) {
		return Wrap(
			alignment: WrapAlignment.center,
			children: [
				AnimatedSwitcher(
					duration: Duration(milliseconds: 400),
					transitionBuilder: (child, animation) {
						final offsetAnimation = Tween<Offset>(begin: Offset(1.2, 0.0), end: Offset(0.0, 0.0)).animate(animation);
						final sizeAnimation = Tween<double>(begin: 0, end: 1).animate(animation);
						return ScaleTransition(
							scale: sizeAnimation,
							alignment: Alignment.centerRight,
							child: SizeTransition(
								sizeFactor: sizeAnimation,
								axisAlignment: 1,
								axis: Axis.horizontal,
								child: SlideTransition(
									position: offsetAnimation,
									child: child
								)
							)
						);
					},
					layoutBuilder: (Widget currentChild, List<Widget> previousChildren) {
						List<Widget> children = previousChildren;
						if (currentChild != null)
							children = children.toList()..add(currentChild);
						return Stack(
							children: children,
							alignment: Alignment.center,
							overflow: Overflow.visible
						);
					},
					child: widget.plan.tasks.isNotEmpty ?
						Container(
							margin: EdgeInsets.symmetric(vertical: 10.0), 
							padding: EdgeInsets.only(right: 6.0),
							child: FloatingActionButton(
								heroTag: null,
								mini: true,
								tooltip: AppLocales.of(context).translate('actions.clearAll'),
								elevation: 4.0,
								child: Padding(padding: EdgeInsets.all(6.0), child: Icon(Icons.delete_sweep)),
								shape: CircleBorder(),
								backgroundColor: Colors.red,
								onPressed: () { clearAllTasks(); }
							)
						) 
						: SizedBox.shrink()
				),
				Container(
					margin: EdgeInsets.symmetric(vertical: 10.0), 
					child: FloatingActionButton.extended(
						heroTag: "newTaskDialog",
						materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
						elevation: 4.0,
						icon: Icon(Icons.add),
						label: Text(AppLocales.of(context).translate('$_pageKey.addTaskButton')),
						backgroundColor: widget.plan.tasks.length < maxTaskCount ? AppColors.formColor : Colors.grey,
						onPressed: () {
							if(widget.plan.tasks.length < maxTaskCount)
								addNewTask();
							else
								showTaskLimitDialog(context);
						}
					)
				)
			]
		);
	}

	void showTaskLimitDialog(BuildContext context) {
		showBasicDialog(
			context,
			GeneralDialog.discard(
				title: AppLocales.of(context).translate('$_pageKey.taskLimitTitle'),
				content: AppLocales.of(context).translate('$_pageKey.taskLimitText', {
					'TASK_LIMIT_NUM': maxTaskCount.toString()
				})
			)
		);
	}

}
