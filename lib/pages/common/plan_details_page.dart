import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/plan_cubit.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/navigation/plan_form_params.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/task/ui_task.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:fokus/widgets/cards/task_card.dart';

class PlanDetailsPage extends StatefulWidget {
  @override
  _PlanDetailsPageState createState() => new _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
	static const String _pageKey = 'page.caregiverSection.planDetails';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SimpleStatefulBlocBuilder<PlanCubit, PlanCubitState>(
          builder: (context, state) => _buildView(context, state),
          loadingBuilder: (_, __) => SizedBox.shrink(),
          listener: (context, state) {
            if (state.submitted)
              showSuccessSnackbar(context, '$_pageKey.content.planRemovedText');
          },
          popConfig: SubmitPopConfig(count: 2, moment: DataSubmissionState.submissionSuccess),
        ),
        floatingActionButton: SimpleStatefulBlocBuilder<PlanCubit, PlanCubitState>(
            builder: (context, state) => _buildFloatingButton(state)
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
	}

	Widget _buildFloatingButton(PlanCubitState state) {
		// ignore: close_sinks
		var authenticationBloc = context.read<AuthenticationBloc>();
		var currentUser = authenticationBloc.state.user;

		return (state.uiPlan.createdBy != currentUser!.id && currentUser.role == UserRole.caregiver) ? FloatingActionButton.extended(
			heroTag: null,
			materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
			backgroundColor: AppColors.formColor,
			elevation: 4.0,
			icon: Icon(Icons.control_point_duplicate),
			label: Text(AppLocales.of(context).translate('$_pageKey.content.copyPlanButton')),
			onPressed: () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name, arguments: PlanFormParams(type: AppFormType.copy, id: state.uiPlan.id)),
		) : SizedBox.shrink();
	}

	Column _buildView(BuildContext context, PlanCubitState state) {
  	return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			verticalDirection: VerticalDirection.up,
			children: [
				AppSegments(segments: _buildPanelSegments(state)),
				_getCardHeader(state.uiPlan, state.children, context)
			],
		);
	}

	List<Widget> _buildPanelSegments(PlanCubitState state) {
  	List<UITask> mandatoryTasks = state.tasks.where((task) => task.optional == false).toList();
		List<UITask> optionalTasks = state.tasks.where((task) => task.optional == true).toList();

		return [
			if(mandatoryTasks.isNotEmpty) _getTasksSegment(
				title: '$_pageKey.content.mandatoryTasks',
				tasks: mandatoryTasks
			),
			if(optionalTasks.isNotEmpty) _getTasksSegment(
				title: '$_pageKey.content.additionalTasks',
				tasks: optionalTasks,
				isOptional: true
			)
		];
	}

	Segment _getTasksSegment({required String title, required List<UITask> tasks, bool isOptional = false}) {
		return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				for (var task in tasks)
					Padding(
						padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
						child: TaskCard(
							index: !isOptional ? tasks.indexOf(task) : null,
							task: TaskFormModel(
								optional: isOptional,
								key: ValueKey(DateTime.now()),
								title: task.name,
								timer: task.timer,
								pointsValue: task.points != null ? task.points!.quantity : null,
								pointCurrency:  task.points != null ? UICurrency(type: task.points!.type, title: task.points!.title) : null
							)
						)
					)
			]
		);
	}

	Widget _getCardHeader(UIPlan plan, Map<Mongo.ObjectId, String> children, BuildContext context) {
  	int i = 0;
		// ignore: close_sinks
		var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
		var currentUser = authenticationBloc.state.user;

		return CustomContentAppBar(
			title: '$_pageKey.header.title',
			content: ItemCard(
				title: plan.name!,
				subtitle: plan.description!(context),
				//TODO: Open child page with click on chip
				chips: <Widget>[
					if (currentUser!.role == UserRole.child || currentUser.id != plan.createdBy)
						AttributeChip.withIcon(
							content: AppLocales.of(context).translate('page.caregiverSection.plans.content.tasks', {'NUM_TASKS': plan.taskCount!}),
							color: Colors.indigo,
							icon: Icons.layers
						)
					else if (children.isNotEmpty)
						for(var child in children.keys)
							AttributeChip(
								content: children[child],
								color:  AppColors.markerColors[i++ % AppColors.markerColors.length]
							)
					else
						AttributeChip(
							content: AppLocales.of(context).translate('$_pageKey.header.noChildren'),
							color:  AppColors.markerColors[i++ % AppColors.markerColors.length]
						)
				]
			),
			helpPage: 'plan_info',
			popupMenuWidget: currentUser.id == plan.createdBy ? PopupMenuList(
				lightTheme: true,
				items: [
					UIButton.ofType(ButtonType.edit, () => Navigator.of(context).pushNamed(
							AppPage.caregiverPlanForm.name,
							arguments: PlanFormParams(type: AppFormType.edit, id: plan.id)
						),
						null, Icons.edit
					),
					UIButton.ofType(
						ButtonType.delete,
						() => showBasicDialog(
							context,
							GeneralDialog.confirm(
								title: AppLocales.of(context).translate('alert.deletePlan'),
								richContent: RichText(
									text: TextSpan(
										text: AppLocales.of(context).translate('alert.confirmPlanDeletion') + '\n\n',
										style: TextStyle(color: AppColors.darkTextColor),
										children: [TextSpan(
											text: AppLocales.of(context).translate('deleteWarning'),
											style: TextStyle(color: Colors.red),
										)]
									),
								),
								confirmText: 'actions.delete',
								confirmAction: () => context.read<PlanCubit>().deletePlan(),
								confirmColor: Colors.red
							)
						),
						null,
						Icons.delete
					)
				]
			) : null
		);
	}
}
