import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../logic/common/calendar_cubit.dart';
import '../../model/db/date/date.dart';
import '../../model/db/plan/plan.dart';
import '../../model/ui/app_page.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/calendar_utils.dart';
import '../../utils/ui/theme_config.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/chips/attribute_chip.dart';
import '../../widgets/segment.dart';

class ChildCalendarPage extends StatefulWidget {
	@override
	_ChildCalendarPageState createState() => _ChildCalendarPageState();
}

class _ChildCalendarPageState extends State<ChildCalendarPage> with TickerProviderStateMixin {
	static const String _pageKey = 'page.childSection.calendar';

	final DateTime kNow = DateTime.now();
	DateTime kFirstDay = DateTime(2000);
	DateTime kLastDay = DateTime(2200);
  DateTime _focusedDay = Date.now();
  late DateTime _selectedDay;

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
	late ValueNotifier<List<Plan>> _selectedEvents;
	final Color notAssignedPlanMarkerColor = Colors.grey[400]!;

	@override
	void initState() {
		super.initState();
		kFirstDay = DateTime(kNow.year, kNow.month - 6, kNow.day);
		kLastDay = DateTime(kNow.year, kNow.month + 6, kNow.day);

    _selectedDay = _focusedDay;
		_selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
	}

	@override
	void dispose() {
		_selectedEvents.dispose();
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
											BlocProvider.of<CalendarCubit>(context).loadInitialData();
										return _buildCalendar();
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
						if(state.events != null && state.events![state.day] != null)
							for(Plan plan in state.events![state.day]!)
								ItemCard(
									title: plan.name!,
									subtitle: plan.description,
									onTapped: () => Navigator.of(context).pushNamed(AppPage.planDetails.name, arguments: plan.id),
									chips: [
										AttributeChip.withIcon(
											icon: Icons.description,
											color: AppColors.mainBackgroundColor,
											content: AppLocales.of(context).translate('plans.tasks', {'NUM_TASKS': plan.tasks!.length})
										)
									]
								)
					]
				);
			}
		);
	}

  List<Plan> _getEventsForDay(DateTime day) {
		var events = BlocProvider.of<CalendarCubit>(context).state.events;
    return events != null && events[Date.fromDate(day)] != null ? events[Date.fromDate(day)]! : [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
				_selectedEvents.value = _getEventsForDay(selectedDay);
      });
			BlocProvider.of<CalendarCubit>(context).dayChanged(Date.fromDate(selectedDay));
    }
  }

	void _onPageChanged(DateTime focusedDay) {
		setState(() {
      _selectedDay = focusedDay;
			_focusedDay = focusedDay;
			_selectedEvents.value = _getEventsForDay(focusedDay);
		});
		BlocProvider.of<CalendarCubit>(context).dayChanged(Date.fromDate(focusedDay));
		BlocProvider.of<CalendarCubit>(context).monthChanged(Date.fromDate(focusedDay));
	}

	TableCalendar _buildCalendar() {
		return TableCalendar<Plan>(
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
					final markers = <Widget>[];
					if (events.isNotEmpty) {
						var planMarkers = <Color>[];
						events.forEach((plan) { planMarkers.add(AppColors.childButtonColor); });
						markers.add(buildMarker(colorList: planMarkers, inPast: date.isBefore(Date.now())));
					}
					return Wrap(children: markers);
				}
			)
		);
	}

}
