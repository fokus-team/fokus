import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/utils/navigation_utils.dart';
import 'package:intl/intl.dart';
import 'package:smart_select/smart_select.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/logic/common/calendar_cubit.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/navigation/plan_form_params.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/utils/ui/calendar_utils.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_confirm_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:fokus/widgets/general/app_hero.dart';

class CaregiverCalendarPage extends StatefulWidget {
	@override
	_CaregiverCalendarPageState createState() => new _CaregiverCalendarPageState();
}

class _CaregiverCalendarPageState extends State<CaregiverCalendarPage> with TickerProviderStateMixin {
	static const String _pageKey = 'page.caregiverSection.calendar';

	final DateTime kNow = DateTime.now();
	DateTime kFirstDay = DateTime(2000);
	DateTime kLastDay = DateTime(2200);
  DateTime _focusedDay = Date.now();
  DateTime? _selectedDay;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
	ValueNotifier<List<UIPlan>>? _selectedEvents;
	final Color notAssignedPlanMarkerColor = Colors.grey[400]!;
	
	bool canAddPlan = true;
	List<UIChild>? _selectedChildren = [];

	@override
	void initState() {
		super.initState();
		kFirstDay = DateTime(kNow.year, kNow.month - 6, kNow.day);
		kLastDay = DateTime(kNow.year, kNow.month + 6, kNow.day);

    _selectedDay = _focusedDay;
		_selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
	}

	@override
	void dispose() {
		_selectedEvents?.dispose();
		super.dispose();
	}

	Color _getChildColor(Map<UIChild?, bool>? children, Mongo.ObjectId childID) {
		int childIndex = children!.keys.toList().indexWhere((element) => element != null && element.id == childID);
		return (childIndex != -1) ? AppColors.markerColors[childIndex % AppColors.markerColors.length] : Colors.cyan;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				verticalDirection: VerticalDirection.up,
				children: [
					AppSegments(
						segments: [
							Padding(
								padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
								child: BlocBuilder<CalendarCubit, CalendarState>(
									builder: (context, state) {
										return _buildCalendar(state.children);
									},
								)
							),
							Padding(
								padding: EdgeInsets.only(top: AppBoxProperties.sectionPadding),
								child: _buildPlanList()
							)
						]
					),
					CustomContentAppBar(
						title: '$_pageKey.header.title',
						content: Card(
							margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0).copyWith(bottom: 6.0),
							child: InkWell(
								onTap: () => {},
								child: Container(
								  child: BlocBuilder<CalendarCubit, CalendarState>(
                    buildWhen: (oldState, newState) => oldState.children != newState.children,
									  builder: (context, state) {
										  if (state.children == null) {
											  BlocProvider.of<CalendarCubit>(context).loadInitialData();
											  return _buildChildPicker(loading: true);
										  }
									    return _buildChildPicker(children: state.children);
									  }
								  )
								)
							)
						)
					)
				]
			),
			floatingActionButton: canAddPlan ? FloatingActionButton.extended(
				onPressed: () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name, arguments: PlanFormParams(type: AppFormType.create, date: BlocProvider.of<CalendarCubit>(context).state.day)),
				label: Text(AppLocales.of(context).translate('$_pageKey.content.addPlan')),
				icon: Icon(Icons.insert_invitation),
				backgroundColor: Colors.lightBlue,
				elevation: 4.0
			) : SizedBox.shrink(),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
		);
	}

	Widget _buildPlanList(){
		return BlocBuilder<CalendarCubit, CalendarState>(
			builder: (context, state) {
				return Segment(
					title: '$_pageKey.content.plansOnDateTitle',
					titleArgs: {'DATE': DateFormat.yMd(AppLocales.instance.locale.toString()).format(state.day).toString()},
					noElementsMessage: '$_pageKey.content.noPlansOnDateTitle',
					noElementsIcon: Icons.description,
					elements: [
						if(state.events != null && state.events![state.day] != null)
							for(UIPlan plan in state.events![state.day]!)
								ItemCard(
									title: plan.name!,
									onTapped: () => navigateChecked(context, AppPage.planDetails, arguments: plan.id),
									subtitle: AppLocales.of(context).translate(
										'$_pageKey.content.${plan.assignedTo!.isNotEmpty ? 'planAssignedToSubtitle' : 'planNotAssignedToSubtitle'}'
									),
									isActive: plan.assignedTo!.isNotEmpty,
									chips: plan.assignedTo!.isNotEmpty ? plan.assignedTo?.map((childID) {
										UIChild? child = state.children?.keys.firstWhere((UIChild? element) => element != null && element.id == childID, orElse: () => null);
										return child != null ? AttributeChip(
											content: child.name,
											color: _getChildColor(state.children!, childID)
										) : SizedBox.shrink();
									}).toList() : []
								)
					]
				);
			}
		);
	}

  List<UIPlan> _getEventsForDay(DateTime day) {
		Map<Date, List<UIPlan>>? events = BlocProvider.of<CalendarCubit>(context).state.events;
    return events != null && events[Date.fromDate(day)] != null ? events[Date.fromDate(day)]! : [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
				_selectedEvents!.value = _getEventsForDay(selectedDay);
      });
			BlocProvider.of<CalendarCubit>(context).dayChanged(Date.fromDate(selectedDay));
    }
  }

	void _onPageChanged(DateTime focusedDay) {
		setState(() {
      _selectedDay = focusedDay;
			_focusedDay = focusedDay;
			_selectedEvents!.value = _getEventsForDay(focusedDay);
		});
		BlocProvider.of<CalendarCubit>(context).dayChanged(Date.fromDate(focusedDay));
		BlocProvider.of<CalendarCubit>(context).monthChanged(Date.fromDate(focusedDay));
	}
	
	TableCalendar _buildCalendar(Map<UIChild?, bool>? children) {
		return TableCalendar<UIPlan>(
			firstDay: kFirstDay,
			lastDay: kLastDay,
			focusedDay: _focusedDay,
			calendarFormat: _calendarFormat,
			rangeSelectionMode: _rangeSelectionMode,
			eventLoader: _getEventsForDay,
			startingDayOfWeek: StartingDayOfWeek.monday,
			calendarStyle: CalendarStyle(
				outsideDaysVisible: false
			),
			headerStyle: HeaderStyle(
				titleCentered: true,
				formatButtonVisible: false
			),
			selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
			onDaySelected: _onDaySelected,
			onPageChanged: _onPageChanged,
			calendarBuilders: CalendarBuilders(
				selectedBuilder: (context, date, _) => buildTableCalendarCell(date, AppColors.caregiverBackgroundColor, isCellSelected: true),
				todayBuilder: (context, date, _) => buildTableCalendarCell(date, Colors.transparent),
				markerBuilder: (context, date, events) {
					final List<Widget> markers = <Widget>[];
					if (events.isNotEmpty) {
						Set<Color> childrenMarkers = {};
						events.forEach((plan) {
							if(plan.assignedTo!.isEmpty)
								childrenMarkers.add(notAssignedPlanMarkerColor);
							else
								plan.assignedTo!.forEach((childID) {
									if(_selectedChildren!.isEmpty || _selectedChildren!.firstWhere((element) => element.id == childID, orElse: () => UIChild(null, '')).id != null)
										childrenMarkers.add(_getChildColor(children, childID));
								});
						});
						markers.add(buildMarker(colorSet: childrenMarkers, inPast: date.isBefore(DateTime.now())));
					}
					return Wrap(children: markers);
				}
			)
		);
	}

	SmartSelect<UIChild> _buildChildPicker({Map<UIChild?, bool>? children = const {}, bool loading = false}) {
	  return SmartSelect<UIChild>.multiple(
	    title: AppLocales.of(context).translate('$_pageKey.header.filterPlansTitle'),
	    selectedValue: _selectedChildren,
	    tileBuilder: (context, selectState) {
	      return InkWell(
	        onTap: () {
	          FocusManager.instance.primaryFocus?.unfocus();
	          if(!loading)
							selectState.showModal();
	        },
	        child: Column(
	          crossAxisAlignment: CrossAxisAlignment.start,
	          children: [
	            ListTile(
	              title: Text(AppLocales.of(context).translate(selectState.selected!.isNotEmpty ?
									'$_pageKey.header.showPlansForTitle'
									: '$_pageKey.header.filterPlansTitle'
								)),
	              trailing: loading ?
									Padding(
										padding: EdgeInsets.only(left: 2.0, top: 2.0),
										child: SizedBox(
											child: CircularProgressIndicator(
												valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
												strokeWidth: 1.5,
											),
											height: 16.0,
											width: 16.0,
										)
									)
									: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
	            ),
							AnimatedSwitcher(
								duration: Duration(milliseconds: 250),
								switchInCurve: Curves.easeIn,
								switchOutCurve: Curves.easeOut,
								transitionBuilder: (child, animation) {
									return SizeTransition(
										sizeFactor: animation,
										axis: Axis.vertical,
										child: child
									);
								},
								child: selectState.selected!.isNotEmpty ?
									Padding(
										padding: EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 10.0),
										child: Wrap(
											spacing: 4.0,
											runSpacing: 4.0,
											children: selectState.selected!.value!.map((child) {
												return AttributeChip(
													content: child.name,
													color: _getChildColor(children, child.id!)
												);
											}).toList(),
										)
									) : SizedBox.shrink()
							)
	          ]
	        )
	      );
	    },
	    choiceItems: S2Choice.listFrom(
	      source: children!.keys.toList(),
	      value: (index, item) => item as UIChild,
	      title: (index, item) => (item as UIChild).name!,
	      meta: (index, item) => item
	    ),
	    choiceType: S2ChoiceType.chips,
			choiceBuilder: (context, selectState, choice) => Theme(
				data: ThemeData(textTheme: Theme.of(context).textTheme),
				child: ItemCard(
					title: choice.title!,
					subtitle: AppLocales.of(context).translate(choice.selected ? 'actions.selected' : 'actions.tapToSelect'),
					graphicType: AssetType.avatars,
					graphic: choice.meta.avatar,
					graphicShowCheckmark: choice.selected,
					graphicHeight: 44.0,
					onTapped: () => choice.select!(!choice.selected),
					isActive: choice.selected
				)
	    ),
			choiceEmptyBuilder: (context, selectState) => AppHero(
				icon: Icons.warning,
				header: AppLocales.of(context).translate('$_pageKey.header.emptyListHeader'),
				title: AppLocales.of(context).translate('$_pageKey.header.emptyListText'),
			),
	    modalType: S2ModalType.bottomSheet,
			modalConfig: S2ModalConfig(
				useConfirm: true
			),
			modalConfirmBuilder: (context, selectState) {
				return ButtonSheetConfirmButton(callback: () => selectState.closeModal(confirmed: true));
			},
	    onChange: (selected) {
				setState(() { _selectedChildren = selected!.value; });
	      Map<UIChild, bool> filter = {};
				for(var child in children.keys)
					filter[child!] = selected!.value!.contains(child);
	      BlocProvider.of<CalendarCubit>(context).childFilterChanged(filter);
	    }
	  );
	}
}
