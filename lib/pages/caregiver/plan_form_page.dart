import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/form/plan_form_model.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/logic/plan_form/plan_form_cubit.dart';

import 'package:fokus/widgets/forms/tasks_list.dart';
import 'package:fokus/widgets/forms/plan_form.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';

enum PlanFormStep { planParameters, taskList }

class CaregiverPlanFormPage extends StatefulWidget {
	@override
	_CaregiverPlanFormPageState createState() => new _CaregiverPlanFormPageState();
}

class _CaregiverPlanFormPageState extends State<CaregiverPlanFormPage> {
	static const String _pageKey = 'page.caregiverSection.planForm';
	final int screenTransitionDuration = 500;
	AppFormType formType;
	PlanFormModel plan = PlanFormModel(); // TODO Edit mode for the form

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
			context.bloc<PlanFormCubit>().submitPlanForm(plan);
		}
	}

	@override
	Widget build(BuildContext context) {
		formKey = GlobalKey<FormState>();
    return BlocConsumer<PlanFormCubit, PlanFormState>(
			listener: (context, state) {
				if (state is PlanFormSubmissionSuccess)
					Navigator.of(context).pop(); // TODO also show some visual feedback?
				else if (state is PlanFormDataLoadSuccess)
					setState(() => plan = state.planForm);
			},
	    builder: (context, state) {
				List<Widget> children = [Scaffold(
					appBar: AppBar(
						title: Text(formType == AppFormType.create ?
						AppLocales.of(context).translate('$_pageKey.createPlanTitle')
								: AppLocales.of(context).translate('$_pageKey.editPlanTitle')
						),
						actions: <Widget>[
							HelpIconButton(helpPage: 'plan_creation')
						],
					),
					body: buildStepper()
				)];
				if (state is PlanFormInitial) {
					formType = state.formType; // works?
					context.bloc<PlanFormCubit>().loadFormData();
					if (formType == AppFormType.edit)
						children.add(Center(child: CircularProgressIndicator()));
				}
				else if (state is PlanFormSubmissionInProgress)
					children.add(Center(child: CircularProgressIndicator()));
		    return WillPopScope(
					onWillPop: () => showExitFormDialog(context, true, state is PlanFormDataLoadSuccess && plan.isDataChanged()),
					child: Stack(
					  children: children
					)
				);
			},
    );
	}

	Widget buildStepOneContent() => PlanForm(
		plan: plan,
		goNextCallback: () {
			if(formKey.currentState.validate() && (plan.repeatability == PlanFormRepeatability.recurring && plan.days.length > 0))
				next();
		}
	);

	Widget buildStepTwoContent() => TaskList(
		plan: plan,
		goBackCallback: back,
		submitCallback: submit,
		isCreateMode: formType == AppFormType.create,
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
