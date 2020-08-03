import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:fokus/model/app_page.dart';
import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/model/ui/plan/ui_plan_form.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/cubit_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/forms/plan_form.dart';
import 'package:fokus/widgets/help_icon_button.dart';
import 'package:fokus/widgets/rounded_button.dart';

class CaregiverPlanFormPage extends StatefulWidget {
	@override
	_CaregiverPlanFormPageState createState() => new _CaregiverPlanFormPageState();
}

class _CaregiverPlanFormPageState extends State<CaregiverPlanFormPage> {
	static const String _pageKey = 'page.caregiverSection.planForm';
	VoidCallback _onStepContinue;
	VoidCallback _onStepCancel;
	final int stepCount = 2;
	int currentStep = 0;
	bool complete = false;
	UIPlanForm planForm = UIPlanForm();
	GlobalKey<FormState> formKey;

	next() {
		currentStep + 1 != stepCount ? goTo(currentStep + 1) : setState(() => complete = true);
	}

	cancel() {
		if (currentStep > 0)
			goTo(currentStep - 1);
	}

	goTo(int step) {
		setState(() => currentStep = step);
	}

	@override
	Widget build(BuildContext context) {
		AppFormType formType = ModalRoute.of(context).settings.arguments;
		formKey = GlobalKey<FormState>();
		
    return CubitUtils.navigateOnState<ActiveUserCubit, ActiveUserState, NoActiveUser>(
			navigation: (navigator) => navigator.pushReplacementNamed(AppPage.rolesPage.name),
			child: Scaffold(
				appBar: AppBar(
					title: Text((formType == AppFormType.create) ?
						AppLocales.of(context).translate('$_pageKey.createPlanTitle')
						: AppLocales.of(context).translate('$_pageKey.editPlanTitle')
					),
					actions: <Widget>[
						HelpIconButton(helpPage: 'plan_creation')
					],
				),
				body: Column(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: <Widget>[
						Expanded(
            	child: Form(
								key: formKey,
								child: Stepper(
									steps: [
										buildStep(context, 0, '$_pageKey.stepOneTitle'),
										buildStep(context, 1, '$_pageKey.stepTwoTitle')
									],
									currentStep: currentStep,
									onStepContinue: next,
									onStepTapped: (step) => goTo(step),
									onStepCancel: cancel,
									type: StepperType.horizontal,
									controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
										_onStepContinue = onStepContinue;
										_onStepCancel = onStepCancel;
										return SizedBox.shrink();
									}
								)
							)
						),
						buildStepButtonsBar(context)
					]
				)
	    )
    );
	}

	Step buildStep(BuildContext context, int index, String title) {
		return Step(
			title: Text(AppLocales.of(context).translate('$_pageKey.step', {'NUM_STEP': index+1}),
				style: Theme.of(context).textTheme.headline3
			),
			subtitle: Text(AppLocales.of(context).translate(title),
				style: Theme.of(context).textTheme.bodyText2
			),
			isActive: currentStep == index,
			content: (index == 0) ? buildStepOneContent(context) : buildStepTwoContent(context)
		);
	}

	Widget buildStepButtonsBar(BuildContext context) {
		AppFormType formType = ModalRoute.of(context).settings.arguments;

		return Material(
			elevation: 10.0,
			child: Container(
				margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
				child: ConstrainedBox(
					constraints: BoxConstraints.tightFor(height: 50.0),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: <Widget>[
							(currentStep == 1) ?
								FlatButton(
									onPressed: () => _onStepCancel(),
									textColor: AppColors.mediumTextColor,
									child: Row(children: <Widget>[Icon(Icons.chevron_left), Text(AppLocales.of(context).translate('actions.back'))]),
								)
								: SizedBox.shrink(),
							FlatButton(
								onPressed: () => {
									if(formKey.currentState.validate())
										_onStepContinue()
								},
								textColor: AppColors.mainBackgroundColor,
								child: (currentStep == 0) ? 
									Row(children: <Widget>[Text(AppLocales.of(context).translate('actions.next')), Icon(Icons.chevron_right)])
									: Text(AppLocales.of(context).translate('$_pageKey.${(formType == AppFormType.create) ? 'createPlanButton' : 'savePlanButton'}'))
							)
						]
					)
				)
			)
		);
	}

	Widget buildStepOneContent(BuildContext context) {
		return PlanForm(plan: planForm);
	}

	Widget buildStepTwoContent(BuildContext context) {
		return Column(
			children: <Widget>[
				Wrap(
					runAlignment: WrapAlignment.spaceAround,
					children: <Widget>[
						RoundedButton(
							text: AppLocales.of(context).translate('$_pageKey.addTaskButton'),
							icon: Icons.add,
							onPressed: () => { log("nowe zadanie") },
							dense: true
						),
						RoundedButton(
							text: AppLocales.of(context).translate('actions.clearAll'),
							color: Colors.red,
							icon: Icons.delete,
							onPressed: () => { log("wyczyść wszystkie") },
							dense: true
						)
					]
				),
				// if(planForm.tasks.isNotEmpty)
				// 	SizedBox(
				// 		height: 400,
				// 		child: ReorderableListView(
				// 			onReorder: _onReorder,
				// 			scrollDirection: Axis.vertical,
				// 			children: List.generate(
				// 				planForm.tasks.length,
				// 				(index) {
				// 					return ListTile(
				// 						key: Key('$index'),
				// 						leading: Text(index.toString()),
				// 						title: Text(planForm.tasks[index].title)
				// 					);
				// 				},
				// 			)
				// 		)
				// 	)
			]
		);
	}

	// void _onReorder(int oldIndex, int newIndex) {
  //   setState(() {
	// 		if (newIndex > oldIndex)
	// 			newIndex -= 1;
	// 		final UITaskForm item = planForm.tasks.removeAt(oldIndex);
	// 		planForm.tasks.insert(newIndex, item);
  //   });
  // }

}
