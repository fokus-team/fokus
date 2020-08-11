import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:fokus/model/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan_form.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';

import 'package:fokus/widgets/forms/tasks_list.dart';
import 'package:fokus/widgets/forms/plan_form.dart';
import 'package:fokus/widgets/help_icon_button.dart';

enum PlanFormStep { planParameters, taskList }

class CaregiverPlanFormPage extends StatefulWidget {
	@override
	_CaregiverPlanFormPageState createState() => new _CaregiverPlanFormPageState();
}

class _CaregiverPlanFormPageState extends State<CaregiverPlanFormPage> {
	static const String _pageKey = 'page.caregiverSection.planForm';
	final int screenTransitionDuration = 500;

	PlanFormStep currentStep = PlanFormStep.planParameters;
	UIPlanForm plan = UIPlanForm(); // TODO Edit mode for the form

	GlobalKey<FormState> formKey;
	GlobalKey<TaskListState> taskListState;

	bool isCurrentStepOne() => (currentStep == PlanFormStep.planParameters);
	bool isCurrentModeCreate() => (ModalRoute.of(context).settings.arguments == AppFormType.create);

	void next() => setState(() { currentStep = PlanFormStep.taskList; });
	void back() => setState(() { currentStep = PlanFormStep.planParameters; });
	void submit() {
		if(plan.tasks.isEmpty) {
			showBasicDialog(
				context,
				GeneralDialog.discard(
					title: AppLocales.of(context).translate('$_pageKey.taskListEmptyTitle'),
					content: AppLocales.of(context).translate('$_pageKey.taskListEmptyText')
				)
			);
		} else {
			log("Dodaj/edytuj plan"); /* TODO Form submit */ 
		}
	}

	@override
	Widget build(BuildContext context) {
		formKey = GlobalKey<FormState>();
		taskListState = GlobalKey<TaskListState>();
    return Scaffold(
			appBar: AppBar(
				title: Text(isCurrentModeCreate() ?
					AppLocales.of(context).translate('$_pageKey.createPlanTitle')
					: AppLocales.of(context).translate('$_pageKey.editPlanTitle')
				),
				actions: <Widget>[
					HelpIconButton(helpPage: 'plan_creation')
				],
			),
			body: buildStepper(context)
    );
	}

	Widget buildStepOneContent(BuildContext context) => PlanForm(
		plan: plan,
		goNextCallback: () {
			if(formKey.currentState.validate())
				next();
		}
	);

	Widget buildStepTwoContent(BuildContext context) => TaskList(
		plan: plan,
		key: taskListState,
		goBackCallback: back,
		submitCallback: submit,
		isCreateMode: isCurrentModeCreate(),
	); 

	Widget buildStepper(BuildContext context) {
		return Column(
			children: <Widget>[
				Container(
					margin: EdgeInsets.zero,
					width: double.infinity,
					decoration: AppBoxProperties.elevatedContainer,
					child: Padding(
						padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
						child: AnimatedSwitcher(
							duration: Duration(milliseconds: screenTransitionDuration),
							transitionBuilder: (Widget child, Animation<double> animation) {
								final inAnimation = Tween<Offset>(begin: Offset(-2.0, 0.0), end: Offset(0.0, 0.0)).animate(animation);
								return SlideTransition(
									position: inAnimation,
									child: child
								);
							},
							layoutBuilder: (Widget currentChild, List<Widget> previousChildren) {
								List<Widget> children = previousChildren;
								if (currentChild != null)
									children = children.toList()..add(currentChild);
								return Stack(
									children: children,
									alignment: Alignment.centerLeft,
								);
							},
							child: Column(
								key: ValueKey(currentStep),
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									Text(
										AppLocales.of(context).translate('$_pageKey.step', {'NUM_STEP': (isCurrentStepOne() ? '1' : '2')}) + '/2',
										style: Theme.of(context).textTheme.headline2
									),
									Text(AppLocales.of(context).translate(isCurrentStepOne() ? '$_pageKey.stepOneTitle' : '$_pageKey.stepTwoTitle'),
										style: Theme.of(context).textTheme.bodyText2
									)
								]
							)
						)
					)
				),
				Expanded(
					child: AnimatedSwitcher(
						switchInCurve: Curves.easeInOut,
						switchOutCurve: Curves.easeInOut,
						duration: Duration(milliseconds: screenTransitionDuration),
						reverseDuration: Duration(milliseconds: screenTransitionDuration),
						transitionBuilder: (Widget child, Animation<double> animation) {
							final inAnimation = Tween<Offset>(begin: Offset(1.5, 0.0), end: Offset(0.0, 0.0)).animate(animation);
							final outAnimation = Tween<Offset>(begin: Offset(-1.5, 0.0), end: Offset(0.0, 0.0)).animate(animation);
							if (child.key == ValueKey(PlanFormStep.taskList)) {
								return ClipRect(
									child: SlideTransition(
										position: inAnimation,
										child: child
									)
								);
							} else {
								return ClipRect(
									child: SlideTransition(
										position: outAnimation,
										child: child
									)
								);
							}
						},
						layoutBuilder: (Widget currentChild, List<Widget> previousChildren) {
							List<Widget> children = previousChildren;
							if (currentChild != null)
								children = children.toList()..add(currentChild);
							return Stack(
								children: children,
								alignment: Alignment.topLeft,
							);
						},
						child: Container(
							key: ValueKey(currentStep),
							child: Form(
								key: formKey,
								child: isCurrentStepOne() ? buildStepOneContent(context) : buildStepTwoContent(context)
							)
						)
					)
				)
			]
		);
	}

}
