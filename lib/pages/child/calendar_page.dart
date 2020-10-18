import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';

import 'package:fokus/logic/common/calendar_cubit.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/utils/ui/calendar_utils.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/segment.dart';

class ChildCalendarPage extends StatefulWidget {
	@override
	_ChildCalendarPageState createState() => new _ChildCalendarPageState();
}

class _ChildCalendarPageState extends State<ChildCalendarPage> with TickerProviderStateMixin {
	static const String _pageKey = 'page.childSection.calendar';
	AnimationController _animationController;
	CalendarController _calendarController;

	final Duration _animationDuration = Duration(milliseconds: 250);

	@override
	void initState() {
		super.initState();
		_calendarController = CalendarController();
		_animationController = AnimationController(vsync: this, duration: _animationDuration);
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
			appBar: AppBar(
				title: Text(AppLocales.of(context).translate('$_pageKey.header.title')),
			),
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppSegments(
						segments: [
							Padding(
								padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
								child: BlocBuilder<CalendarCubit, CalendarState>(
									builder: (context, state) {
										if (state.children == null)
											context.bloc<CalendarCubit>().loadInitialData();
										return _buildCalendar(state.events, state.children);
									},
								)
							),
							Padding(
								padding: EdgeInsets.only(top: AppBoxProperties.sectionPadding),
								child: _buildPlanList()
							)
						]
					)
				]
			)
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
						if(state.events != null && state.events[state.day] != null)
							for(UIPlan plan in state.events[state.day])
								ItemCard(
									title: plan.name,
									subtitle: plan.description(context),
									onTapped: () => Navigator.of(context).pushNamed(AppPage.planDetails.name, arguments: plan.id),
									chips: [
										AttributeChip.withIcon(
											icon: Icons.description,
											color: AppColors.mainBackgroundColor,
											content: AppLocales.of(context).translate('plans.tasks', {'NUM_TASKS': plan.taskCount})
										)
									]
								)
					]
				);
			}
		);
	}

	TableCalendar _buildCalendar(Map<Date, List<UIPlan>> events, Map<UIChild, bool> children) {
	  return buildCalendar(
			controller: _calendarController, 
			context: context,
			events: events,
			onDaySelected: onDayChanged,
			onCalendarCreated: onCalendarCreated,
			onVisibleDaysChanged: onMonthChanged,
			builders: CalendarBuilders(
				selectedDayBuilder: (context, date, _) =>
          FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: buildTableCalendarCell(date, AppColors.childBackgroundColor, isCellSelected: true)
					),
        todayDayBuilder: (context, date, _) => buildTableCalendarCell(date, Colors.transparent),
				markersBuilder: (context, date, events, holidays) {
					final markers = <Widget>[];
					if (events.isNotEmpty) {
						List<Color> planMarkers = [];
						events.forEach((plan) { planMarkers.add(AppColors.childButtonColor); });
						markers.add(buildMarker(colorList: planMarkers));
					}
					return markers;
				}
			)
		);
	}

	void onDayChanged(DateTime day, List<dynamic> events) {
		context.bloc<CalendarCubit>().dayChanged(Date.fromDate(day));
		_animationController.forward(from: 0.0);
	}

	void onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
		context.bloc<CalendarCubit>().monthChanged(Date.fromDate(_calendarController.focusedDay));
	}

	void onMonthChanged(DateTime first, DateTime last, CalendarFormat format) {
		onCalendarCreated(first, last, format);
		_calendarController.setSelectedDay(Date.fromDate(Utils.firstDayOfMonth(_calendarController.focusedDay)));
	}

}
