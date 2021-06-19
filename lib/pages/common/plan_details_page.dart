import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../../logic/common/auth_bloc/authentication_bloc.dart';
import '../../logic/common/plan_cubit.dart';
import '../../model/db/gamification/currency.dart';
import '../../model/db/plan/plan.dart';
import '../../model/db/plan/task.dart';
import '../../model/db/user/user_role.dart';
import '../../model/navigation/plan_form_params.dart';
import '../../model/ui/app_page.dart';
import '../../model/ui/form/task_form_model.dart';
import '../../model/ui/ui_button.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/dialog_utils.dart';
import '../../utils/ui/snackbar_utils.dart';
import '../../utils/ui/theme_config.dart';
import '../../widgets/buttons/popup_menu_list.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/cards/task_card.dart';
import '../../widgets/chips/attribute_chip.dart';
import '../../widgets/custom_app_bars.dart';
import '../../widgets/dialogs/general_dialog.dart';
import '../../widgets/segment.dart';
import '../../widgets/stateful_bloc_builder.dart';

class PlanDetailsPage extends StatefulWidget {
  @override
  _PlanDetailsPageState createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
	static const String _pageKey = 'page.caregiverSection.planDetails';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StatefulBlocBuilder<PlanCubit, PlanData>(
        builder: (_, state) => _buildView(state.data!),
        loadingBuilder: (_, __) => SizedBox.shrink(),
        listener: (context, state) {
          if (state.submitted)
            showSuccessSnackbar(context, '$_pageKey.content.planRemovedText');
        },
        popConfig: SubmitPopConfig.onSubmitted(count: 2),
      ),
      floatingActionButton: StatefulBlocBuilder<PlanCubit, PlanData>(
          builder: (context, state) => _buildFloatingButton(state.data!)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
	}

	Widget _buildFloatingButton(PlanData state) {
		// ignore: close_sinks
		var authenticationBloc = context.read<AuthenticationBloc>();
		var currentUser = authenticationBloc.state.user;

		return (state.plan.createdBy != currentUser!.id && currentUser.role == UserRole.caregiver) ? FloatingActionButton.extended(
			heroTag: null,
			materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
			backgroundColor: AppColors.formColor,
			elevation: 4.0,
			icon: Icon(Icons.control_point_duplicate),
			label: Text(AppLocales.of(context).translate('$_pageKey.content.copyPlanButton')),
			onPressed: () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name, arguments: PlanFormParams(type: AppFormType.copy, id: state.plan.id)),
		) : SizedBox.shrink();
	}

	Column _buildView(PlanData state) {
  	return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			verticalDirection: VerticalDirection.up,
			children: [
				AppSegments(segments: _buildPanelSegments(state)),
				_getCardHeader(state.plan, state.children, context)
			],
		);
	}

	List<Widget> _buildPanelSegments(PlanData state) {
  	var mandatoryTasks = state.tasks.where((task) => task.optional == false).toList();
		var optionalTasks = state.tasks.where((task) => task.optional == true).toList();

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

	Segment _getTasksSegment({required String title, required List<Task> tasks, bool isOptional = false}) {
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
								pointCurrency:  task.points != null ? Currency(type: task.points!.type, name: task.points!.name) : null
							)
						)
					)
			]
		);
	}

	Widget _getCardHeader(Plan plan, Map<mongo.ObjectId, String> children, BuildContext context) {
  	var i = 0;
		// ignore: close_sinks
		var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
		var currentUser = authenticationBloc.state.user;

		return CustomContentAppBar(
			title: '$_pageKey.header.title',
			content: ItemCard(
				title: plan.name!,
				subtitle: plan.description,
				//TODO: Open child page with click on chip
				chips: <Widget>[
					if (currentUser!.role == UserRole.child || currentUser.id != plan.createdBy)
						AttributeChip.withIcon(
							content: AppLocales.of(context).translate('page.caregiverSection.plans.content.tasks', {'NUM_TASKS': plan.tasks!.length}),
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
										text: '${AppLocales.of(context).translate('alert.confirmPlanDeletion')}\n\n',
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
