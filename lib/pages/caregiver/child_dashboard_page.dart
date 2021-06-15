import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:round_spot/round_spot.dart' as round_spot;
import 'package:intl/intl.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:smart_select/smart_select.dart';

import 'package:fokus/logic/caregiver/child_dashboard/child_dashboard_cubit.dart';
import 'package:fokus/logic/caregiver/child_dashboard/dashboard_achievements_cubit.dart';
import 'package:fokus/logic/caregiver/child_dashboard/dashboard_plans_cubit.dart';
import 'package:fokus/logic/caregiver/child_dashboard/dashboard_rewards_cubit.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/navigation/child_dashboard_params.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/model/ui/child_card_model.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/child_plans_util.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_confirm_button.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/model_cards.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/general/app_alert.dart';
import 'package:fokus/widgets/general/app_loader.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverChildDashboardPage extends StatefulWidget {
	final ChildDashboardParams _args;

	CaregiverChildDashboardPage(this._args);

	@override
	_CaregiverChildDashboardPageState createState() => _CaregiverChildDashboardPageState(_args);
}

class _CaregiverChildDashboardPageState extends State<CaregiverChildDashboardPage> with TickerProviderStateMixin {
	static const String _pageKey = 'page.caregiverSection.childDashboard';
	late TabController _tabController;
	final ChildCardModel _childCard;
	int _currentIndex;
  StreamController<int> _tabIndexStream = StreamController<int>.broadcast();

	_CaregiverChildDashboardPageState(ChildDashboardParams args) : _currentIndex = args.tab ?? 0, _childCard = args.childCard;

	final double customBottomBarHeight = 40.0;
	final Duration bottomBarAnimationDuration = Duration(milliseconds: 400);

	@override
	void initState() {
		super.initState();
		_tabController = TabController(initialIndex: _currentIndex, vsync: this, length: 3);
		_tabController.animation!..addListener(() {
		  var newValue = (_tabController.animation!.value).round();
		  if (_currentIndex != newValue) {
        _currentIndex = newValue;

        _tabIndexStream.add(_currentIndex);
      }
		});
	}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
		return Scaffold(
	    body: SimpleStatefulBlocBuilder<ChildDashboardCubit, ChildDashboardState>(
        builder: (context, state) => _getPage(
					childCard: state.childCard,
	        content: TabBarView(
            controller: _tabController,
            children: [
	            _buildTab<DashboardPlansCubit, DashboardPlansState>(_buildPlansTab, 0),
	            _buildTab<DashboardRewardsCubit, DashboardRewardsState>(_buildRewardsTab, 1),
	            _buildTab<DashboardAchievementsCubit, DashboardAchievementsState>(_buildAchievementsTab, 2),
            ]
					)
	      ),
		    loadingBuilder: (context, state) => _getPage(
			    childCard: _childCard,
			    content: Center(child: AppLoader())
		    ),
	    ),
	    bottomNavigationBar: _indexBuildable(_buildBottomBar),
	    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
	    floatingActionButton: _indexBuildable(_buildFloatingButtonAnimation)
		);
	}

	Widget _buildTab<Cubit extends StatefulCubit, State extends StatefulState>(List<Widget> Function(State) content, int index) {
		return SimpleStatefulBlocBuilder<Cubit, State>(
			builder: (context, state) => round_spot.Detector(
				areaID: '$index',
				child: ListView(
					padding: EdgeInsets.zero,
					physics: BouncingScrollPhysics(),
					children: content(state),
				),
			)
		);
	}

	Column _getPage({required ChildCardModel childCard, required Widget content}) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
				verticalDirection: VerticalDirection.up,
			children: [
				Expanded(child: content),
				_buildAppHeader(childCard),
			]
		);
	}

	CustomContentAppBar _buildAppHeader(ChildCardModel childCard) {
		var cubit = BlocProvider.of<ChildDashboardCubit>(context);
    return CustomContentAppBar(
      title: '$_pageKey.header.title',
      content: ChildItemCard(childCard: childCard),
      popupMenuWidget: PopupMenuList(
        lightTheme: true,
        items: [
          UIButton('$_pageKey.header.childCode',() => showUserCodeDialog(context, '$_pageKey.header.childCode', getCodeFromId(childCard.child.id!)),
						null, Icons.screen_lock_portrait ),
          UIButton.ofType(ButtonType.edit, () => cubit.onNameDialogClosed(showNameEditDialog(context, _childCard.child)),
						null, Icons.edit),
          UIButton.ofType(ButtonType.unpair, () async {
            	if ((await showAccountDeleteDialog(context, _childCard.child)) ?? false) {
	            	Navigator.of(context).pop();
								showSuccessSnackbar(context, 'page.settings.content.profile.accountChildDeletedText');
							}
						}, null, Icons.person_remove)
        ],
      ),
      tabs: TabBar(
	      controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3.0,
        tabs: [
          Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.plans')),
          Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.rewards')),
          Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.achievements'))
        ]
      )
    );
  }

  Widget _buildBottomBar(int index) {
    return AnimatedContainer(
      duration: bottomBarAnimationDuration,
      height: index == 1 ? 0 : customBottomBarHeight,
      decoration: AppBoxProperties.elevatedContainer,
      child: SizedBox.shrink()
    );
  }

  Widget _indexBuildable(Widget Function(int) builder) {
    return StreamBuilder<int>(
      stream: _tabIndexStream.stream,
      initialData: _currentIndex,
      builder: (context, index) => builder(index.data!),
    );
  }

	Widget _buildFloatingButtonAnimation(int index) {
		return AnimatedSwitcher(
			duration: bottomBarAnimationDuration,
			switchOutCurve: Curves.easeInOut,
			transitionBuilder: (child, animation) {
				return ScaleTransition(
					scale: animation,
					child: FadeTransition(
						opacity: animation,
						child: child
					)
				);
			},
			child: _buildSelectPopup(index)
		);
	}

	Widget _buildSelectPopup(int index) {
		if (index == 1)
			return SizedBox.shrink();
		if (index == 0)
			return _buildSelect<Plan, DashboardPlansCubit, DashboardPlansState>(
					content: _buildPlanSelect,
					model: (tabState) => tabState.availablePlans
			);
		return _buildSelect<Badge, DashboardAchievementsCubit, DashboardAchievementsState>(
				content: _buildBadgeSelect,
				model: (tabState) => tabState.availableBadges
		);
	}

	Widget _buildSelect<Type, Cubit extends StatefulCubit, State>({required Widget Function([List<Type>]) content, required List<Type> Function(State) model}) {
		return BlocBuilder<Cubit, StatefulState>(
			builder: (context, state) {
				if (!state.loaded)
					return content();
				return content(model(state as State));
			}
		);
	}

	Widget _buildFloatingButtonPicker<T>({
		required String buttonLabel, IconData? buttonIcon, String? disabledDialogTitle, String? disabledDialogText,
		String? pickerTitle, List<T>? pickedValues, required List<T> options,
		required Widget Function(BuildContext, S2MultiState<T>, S2Choice<T>) builder, required Function(List<T>) onChange, required Function(T) getName
	}) {
		bool buttonDisabled = options.isEmpty;
		return SmartSelect<T>.multiple(
			selectedValue: pickedValues,
			title: pickerTitle,
			choiceItems: [
				for(T element in options)
					S2Choice(
						title: getName(element),
						value: element
					)
			],
			onChange: (selected) => onChange(selected!.value!),
			modalType: S2ModalType.bottomSheet,
			choiceBuilder: builder,
			modalConfirmBuilder: (context, selectState) {
				return ButtonSheetConfirmButton(callback: () => selectState.closeModal(confirmed: true));
			},
			modalConfig: S2ModalConfig(
				useConfirm: true,
			),
			tileBuilder: (context, selectState) {
				return FloatingActionButton.extended(
					heroTag: null,
					materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
					backgroundColor: buttonDisabled ? Colors.grey : AppColors.formColor,
					elevation: 4.0,
					icon: Icon(buttonIcon),
					label: Text(buttonLabel),
					onPressed: () => buttonDisabled ?
						showBasicDialog(context,
							GeneralDialog.discard(
								title: disabledDialogTitle!,
								content: disabledDialogText
							)
						) : selectState.showModal()
				);
			}
		);
	}

	Widget _buildPlanSelect([List<Plan> availablePlans = const []]) {
		return _buildFloatingButtonPicker<Plan>(
			buttonLabel: AppLocales.of(context).translate('$_pageKey.header.assignPlanButton'),
			buttonIcon: Icons.description,
			disabledDialogTitle: AppLocales.of(context).translate('$_pageKey.header.assignPlanButton'),
			disabledDialogText: AppLocales.of(context).translate('$_pageKey.content.alerts.noPlansAdded'),
			pickerTitle: AppLocales.of(context).translate('$_pageKey.header.assignPlanTitle'),
			pickedValues: availablePlans.where((element) => element.assignedTo!.contains(_childCard.child.id)).toList(),
			options: availablePlans,
			onChange: (List<Plan>? selected) => context.read<DashboardPlansCubit>().assignPlans(selected == null ? [] : selected.map((plan) => plan.id).toList()),
			getName: (plan) => plan.name,
			builder: (context, selectState, choice) {
				return Theme(
					data: ThemeData(textTheme: Theme.of(context).textTheme),
					child: ItemCard(
						title: choice.title!,
						subtitle: AppLocales.of(context).translate(choice.selected ? 'actions.selected' : 'actions.tapToSelect'),
						icon: Padding(
							padding: EdgeInsets.all(6.0).copyWith(right: 0.0),
							child: CircleAvatar(
								backgroundColor: choice.selected ? Colors.green : Colors.grey,
								radius: 16.0,
								child: choice.selected ? Icon(Icons.check, color: Colors.white, size: 20.0) : SizedBox(height: 20)
							)
						),
						onTapped: () => choice.select!(!choice.selected),
						isActive: choice.selected
					)
				);
			}
		);
	}

	Widget _buildBadgeSelect([List<Badge> availableBadges = const []]) {
		return _buildFloatingButtonPicker<Badge>(
			buttonLabel: AppLocales.of(context).translate('$_pageKey.header.assignBadgeButton'),
			buttonIcon: Icons.star,
			disabledDialogTitle: AppLocales.of(context).translate('$_pageKey.header.assignBadgeButton'),
			disabledDialogText: AppLocales.of(context).translate('$_pageKey.header.noBadgesToAssignText'),
			pickerTitle: AppLocales.of(context).translate('$_pageKey.header.assignBadgeTitle'),
			pickedValues: [],
			options: availableBadges,
			onChange: (List<Badge>? selected) => context.read<DashboardAchievementsCubit>().assignBadges(selected ?? []),
			getName: (badge) => badge.name,
			builder: (context, selectState, choice) {
				return Theme(
					data: ThemeData(textTheme: Theme.of(context).textTheme),
					child: ItemCard(
						title: choice.title!,
						subtitle: AppLocales.of(context).translate(choice.selected ? 'actions.selected' : 'actions.tapToSelect'),
						graphic: choice.value.icon,
						graphicType: AssetType.badges,
						graphicShowCheckmark: choice.selected,
						graphicHeight: 40.0,
						onTapped: () => choice.select!(!choice.selected),
						isActive: choice.selected
					)
				);
			}
		);
	}

	List<Widget> _buildPlansTab(DashboardPlansState state) {
		return [
			if (state.unratedTasks)
				AppAlert(
					text: AppLocales.of(context).translate('$_pageKey.content.alerts.unratedTasksExist'),
					onTap: () => Navigator.of(context).pushNamed(AppPage.caregiverRatingPage.name),
					color: Colors.lightBlue,
					icon: Icons.rate_review
				),
			if (state.noPlansAdded)
				AppAlert(
					text: AppLocales.of(context).translate('$_pageKey.content.alerts.noPlansAdded'),
					onTap: () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name),
				),
			...buildChildPlanSegments(state.childPlans, context),
			SizedBox(height: 30.0)
		];
	}

	List<Widget> _buildRewardsTab(DashboardRewardsState state) {
		return [
			if (state.noRewardsAdded)
				AppAlert(
					text: AppLocales.of(context).translate('$_pageKey.content.alerts.noRewardsAdded'),
					onTap: () => Navigator.of(context).pushNamed(AppPage.caregiverRewardForm.name),
				),
			Segment(
				title: '$_pageKey.content.rewardsTitle',
				noElementsMessage: '$_pageKey.content.noRewardsText',
				elements: [
					for (var reward in state.childRewards)
						RewardItemCard(reward: reward),
				]
			)
		];
	}

	List<Widget> _buildAchievementsTab(DashboardAchievementsState state) {
		return [
			if (state.availableBadges.isEmpty && state.childBadges.isEmpty)
				AppAlert(
					text: AppLocales.of(context).translate('$_pageKey.content.alerts.noBadgesAdded'),
					onTap: () => Navigator.of(context).pushNamed(AppPage.caregiverBadgeForm.name),
				),
			Segment(
				title: '$_pageKey.content.achievementsTitle',
				noElementsMessage: '$_pageKey.content.noAchievementsText',
				noElementsIcon: Icons.star,
				elements: [
					for (var badge in state.childBadges)
						ItemCard(
							title: badge.name!,
							subtitle: AppLocales.of(context).translate('page.childSection.achievements.content.earnedBadgeDate') + ': '
									+ DateFormat.yMd(AppLocales.instance.locale.toString()).format(badge.date!),
							graphicType: AssetType.badges,
							graphic: badge.icon,
							graphicHeight: 44.0,
						)
				]
			)
		];
	}
}
