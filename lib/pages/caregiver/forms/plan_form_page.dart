// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/form/plan_form_model.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/logic/caregiver/forms/plan/plan_form_cubit.dart';

import 'package:fokus/widgets/forms/tasks_list.dart';
import 'package:fokus/widgets/forms/plan_form.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/general/app_loader.dart';

enum PlanFormStep { planParameters, taskList }

class CaregiverPlanFormPage extends StatefulWidget {
	@override
	_CaregiverPlanFormPageState createState() => new _CaregiverPlanFormPageState();
}

class _CaregiverPlanFormPageState extends State<CaregiverPlanFormPage> {
	static const String _pageKey = 'page.caregiverSection.planForm';
	final int screenTransitionDuration = 500;
	AppFormType formType;
	PlanFormModel plan = PlanFormModel();

	PlanFormStep currentStep = PlanFormStep.planParameters;

	GlobalKey<FormState> formKey;

	bool isCurrentStepOne() => (currentStep == PlanFormStep.planParameters);

	void next() => setState(() { currentStep = PlanFormStep.taskList; });
	void back() => setState(() { currentStep = PlanFormStep.planParameters; });
	void submit() {
		if (plan.tasks.isEmpty) {
			showBasicDialog(
				context,
				GeneralDialog.discard(
					title: AppLocales.of(context).translate('$_pageKey.taskListEmptyTitle'),
					content: AppLocales.of(context).translate('$_pageKey.taskListEmptyText')
				)
			);
		} else {
			BlocProvider.of<PlanFormCubit>(context).submitPlanForm(plan);
		}
	}

	@override
	Widget build(BuildContext context) {
		formKey = GlobalKey<FormState>();
    return BlocConsumer<PlanFormCubit, PlanFormState>(
			listener: (context, state) {
				if (state is PlanFormSubmissionSuccess) {
					if(formType == AppFormType.copy) {
						Navigator.of(context).popUntil(ModalRoute.withName(AppPage.planDetails.name));
						Navigator.of(context).pushNamed(AppPage.caregiverPlans.name);
					} else {
						Navigator.of(context).pop();
					}
					showSuccessSnackbar(context, formType == AppFormType.edit ? '$_pageKey.planEditedText' : '$_pageKey.planCreatedText');
				} else if (state is PlanFormDataLoadSuccess)
					setState(() => plan = PlanFormModel.from(state.planForm));
			},
	    builder: (context, state) {
				List<Widget> children = [buildStepper()];
				if (state is PlanFormInitial) {
					formType = state.formType;
					BlocProvider.of<PlanFormCubit>(context).loadFormData();
					if (formType != AppFormType.create) {
						children.add(Positioned(
							child: Center(child: AppLoader(hasOverlay: true))
						));
					}
				}
				else if (state is PlanFormSubmissionInProgress)
					children.add(Positioned(
						child: Center(child: AppLoader(hasOverlay: true))
					));
		    return WillPopScope(
					onWillPop: () => showExitFormDialog(context, true, state is PlanFormDataLoadSuccess && plan != state.planForm),
					child: Scaffold(
						appBar: AppBar(
							title: Text(AppLocales.of(context).translate(
								formType == AppFormType.create ? '$_pageKey.createPlanTitle' : 
									formType == AppFormType.edit ? '$_pageKey.editPlanTitle' : '$_pageKey.copyPlanTitle'
							)),
							actions: <Widget>[
								HelpIconButton(helpPage: 'plan_creation')
							],
						),
						body: Stack(
							children: children
						)
					)
				);
			},
    );
	}

	Widget buildStepOneContent() => PlanForm(
		plan: plan,
		goNextCallback: () {
			if(formKey.currentState.validate())
				if(plan.repeatability == PlanFormRepeatability.onlyOnce ||
					plan.repeatability == PlanFormRepeatability.untilCompleted ||
					(plan.repeatability == PlanFormRepeatability.recurring && plan.days.length > 0))
					next();
		}
	);

	Widget buildStepTwoContent() => TaskList(
		plan: plan,
		goBackCallback: back,
		submitCallback: submit,
		isCreateMode: formType != AppFormType.edit,
	);

	Widget buildStepper() {
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
								child: isCurrentStepOne() ? buildStepOneContent() : buildStepTwoContent()
							)
						)
					)
				)
			]
		);
	}

}
