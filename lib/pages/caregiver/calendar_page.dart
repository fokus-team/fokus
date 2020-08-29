import 'package:badges/badges.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_bar_buttons.dart';
import 'package:intl/intl.dart';
import 'package:smart_select/smart_select.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/logic/calendar_cubit.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverCalendarPage extends StatefulWidget {
	@override
	_CaregiverCalendarPageState createState() => new _CaregiverCalendarPageState();
}

class _CaregiverCalendarPageState extends State<CaregiverCalendarPage> with TickerProviderStateMixin {
	static const String _pageKey = 'page.caregiverSection.calendar';
	AnimationController _animationController;
	CalendarController _calendarController;

	DateTime _selectedDate = Date.now();
	List<UIPlan> _selectedPlans = [];
	Map<UIChild, Color> _childrenColors = {};
	List<UIChild> _selectedChildren = [];

	List<Color> markerColors = [
		Colors.green,
		Colors.pink,
		Colors.deepPurple,
		Colors.teal,
		Colors.orange,
		Colors.red,
		Colors.purple,
		Colors.brown
	];

	@override
	void initState() {
		super.initState();
		_calendarController = CalendarController();
		_animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
		_animationController.forward();
	}

	@override
	void dispose() {
		_calendarController.dispose();
		_animationController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.widget(
						title: '$_pageKey.header.title',
						appHeaderWidget: Card(
							margin: EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 6.0),
							child: InkWell(
								onTap: () => {},
								child: Container(
								  child: BlocBuilder<CalendarCubit, CalendarState>(
									  builder: (context, state) {
										  if (state.children == null) {
											  context.bloc<CalendarCubit>().loadInitialData();
											  return buildChildPicker(loading: true);
										  }
											int markerIndex = 0;
											for(var child in state.children.keys) {
												if(markerIndex == markerColors.length)
													markerIndex = 0;
												_childrenColors[child] = markerColors[markerIndex++];
											}
									    return buildChildPicker(children: state.children);
									  },
								  ),
								)
							)
						)
					),
					AppSegments(
						segments: [
							Padding(
								padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
								child: BlocBuilder<CalendarCubit, CalendarState>(
									builder: (context, state) {
										// if(state.events != null && state.events.isNotEmpty)
										// 	_calendarController.setSelectedDay(_selectedDate.add(Duration(days: 1)), runCallback: true);
										return buildCalendar(state.events);
									},
								)
							),
							Padding(
								padding: EdgeInsets.only(top: 8.0),
								child: Segment(
									title: '$_pageKey.content.plansOnDateTitle',
									titleArgs: {'DATE': DateFormat.yMd(Localizations.localeOf(context).toString()).format(_selectedDate).toString()},
									noElementsMessage: '$_pageKey.content.noPlansOnDateTitle',
									elements: [
										for(UIPlan plan in _selectedPlans)
											ItemCard(
												title: plan.name,
												onTapped: () => Navigator.pushNamed(context, AppPage.caregiverPlanDetails.name, arguments: {'planID': plan.id}),
												subtitle: AppLocales.of(context).translate('$_pageKey.content.planAssignedToSubTitle'),
												chips: plan.assignedTo.map((childID) {
													var child = _childrenColors.keys.firstWhere((element) => element.id == childID);
													return AttributeChip(
														content: child.name,
														color: _childrenColors[child]
													);
												}).toList()
											)
									]
								)
							)
						]
					)
				]
			)
		);
	}

	TableCalendar buildCalendar(Map<Date, List<UIPlan>> events) {
	  return TableCalendar(
			calendarController: _calendarController,
			locale: AppLocales.of(context).locale.toString(),
			availableGestures: AvailableGestures.horizontalSwipe,
			startingDayOfWeek: StartingDayOfWeek.monday,
			initialCalendarFormat: CalendarFormat.month,
			headerStyle: HeaderStyle(
				centerHeaderTitle: true,
				formatButtonVisible: false
			),
			calendarStyle: CalendarStyle(
				selectedColor: Colors.white,
				selectedStyle: TextStyle(color: AppColors.darkTextColor),
				todayColor: Colors.grey,
				contentPadding: EdgeInsets.all(5.0)
			),
			events: events,
			onDaySelected: (day, events) {
				setState(() {
					_selectedDate = day;
					_selectedPlans = events.isNotEmpty ? events : [];
				});
				_animationController.forward(from: 0.0);
			},
			onCalendarCreated: onMonthChanged,
			onVisibleDaysChanged: onMonthChanged,
			builders: CalendarBuilders(
				selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								color: AppColors.caregiverBackgroundColor,
								boxShadow: [
									BoxShadow(color: Colors.black26, blurRadius: 8.0)
								]
							),
							width: 100,
							height: 100,
              child: Center(
								child: Text(
									'${date.day}',
									textAlign: TextAlign.start,
                	style: TextStyle().copyWith(fontSize: 17.0, color: Colors.white, fontWeight: FontWeight.bold)
								)
							)
            )
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
							border: Border.all(color: Colors.grey[400], width: 1.0),
								shape: BoxShape.circle,
						),
            width: 100,
            height: 100,
						child: Center(
							child: Text(
								'${date.day}',
								textAlign: TextAlign.start,
								style: TextStyle().copyWith(fontSize: 15.0)
							)
						)
          );
        },
				markersBuilder: (context, date, events, holidays) {
					final children = <Widget>[];
					if (events.isNotEmpty) {
						Set<Color> childrenMarkers = {};
						events.forEach((plan) {
							plan.assignedTo.forEach((childID) {
								childrenMarkers.add(_childrenColors[_childrenColors.keys.firstWhere((element) => element.id == childID)]);
							});
						});
						children.add(
							Positioned(
								left: 6.0,
								right: 6.0,
								bottom: 0,
								child: Wrap(
									alignment: WrapAlignment.center,
									spacing: 2.0,
									children: childrenMarkers.take(4).map((marker) => Badge(
										badgeColor: marker,
										elevation: 0,
										padding: EdgeInsets.all(3.6),
										animationType: BadgeAnimationType.scale
									)).toList()
								)
							)
						);
					}
					return children;
				}
			)
		);
	}

	void onMonthChanged(DateTime first, DateTime last, CalendarFormat format) {
		context.bloc<CalendarCubit>().monthChanged(Date.fromDate(Utils.firstDayOfMonth(_calendarController.focusedDay)));
	}

	SmartSelect<UIChild> buildChildPicker({Map<UIChild, bool> children = const {}, bool loading = false}) {
	  return SmartSelect<UIChild>.multiple(
	    title: AppLocales.of(context).translate('$_pageKey.header.filterPlansTitle'),
	    isLoading: loading, // Add AppLoader to builder
	    value: _selectedChildren,
	    builder: (context, state, callback) {
	      return InkWell(
	        onTap: () {
	          FocusManager.instance.primaryFocus.unfocus();
	          callback(context);
	        },
	        child: Column(
	          crossAxisAlignment: CrossAxisAlignment.start,
	          children: [
	            ListTile(
	              title: Text(
									AppLocales.of(context).translate(state.values.isNotEmpty ? '$_pageKey.header.showPlansForTitle' : '$_pageKey.header.filterPlansTitle')
								),
	              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
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
								child: state.values.isNotEmpty ?
									Padding(
										padding: EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 10.0),
										child: Wrap(
											spacing: 4.0,
											runSpacing: 4.0,
											children: state.values.map((child) {
												return AttributeChip(
													content: child.name,
													color: _childrenColors[child]
												);
											}).toList(),
										)
									) : SizedBox.shrink()
							)
	          ]
	        )
	      );
	    },
	    options: SmartSelectOption.listFrom(
	      source: children.keys.toList(),
	      value: (index, item) => item,
	      title: (index, item) => item.name,
	      meta: (index, item) => item
	    ),
	    choiceType: SmartSelectChoiceType.chips,
	    choiceConfig: SmartSelectChoiceConfig(
	      builder: (item, checked, onChange) => Theme(
	        data: ThemeData(textTheme: Theme.of(context).textTheme),
	        child: ItemCard(
	          title: item.title,
	          subtitle: AppLocales.of(context).translate(checked ? 'actions.selected' : 'actions.tapToSelect'),
	          graphicType: GraphicAssetType.childAvatars,
	          graphic: item.meta.avatar,
	          graphicShowCheckmark: checked,
	          graphicHeight: 44.0,
	          onTapped: onChange != null ? () => onChange(item.value, !checked) : null,
	          isActive: checked
	        )
	      )
	    ),
	    modalType: SmartSelectModalType.bottomSheet,
			modalConfig: SmartSelectModalConfig(
				trailing: ButtonSheetBarButtons(
					buttons: [
						UIButton('actions.confirm', () { Navigator.pop(context); }, Colors.green, Icons.done)
					],
				)
			),
	    onChange: (val) {
				setState(() { _selectedChildren = val; });
	      Map<UIChild, bool> filter = {};
				for(var child in children.keys)
					filter[child] = val.isEmpty ? true : val.contains(child);
	      context.bloc<CalendarCubit>().childFilterChanged(filter);
	    }
	  );
	}
}
