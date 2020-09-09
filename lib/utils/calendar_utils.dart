import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/services/app_locales.dart';

Widget buildCalendar(
	CalendarController controller,
	BuildContext context,
	Map<Date, List<UIPlan>> events,
	Function(DateTime, List<dynamic>) onDaySelected,
	Function(DateTime, DateTime, CalendarFormat) onCalendarCreated,
	Function(DateTime, DateTime, CalendarFormat) onVisibleDaysChanged,
	CalendarBuilders builders
) {
	return TableCalendar(
			calendarController: controller,
			locale: AppLocales.of(context).locale.toString(),
			availableGestures: AvailableGestures.horizontalSwipe,
			startingDayOfWeek: StartingDayOfWeek.monday,
			initialCalendarFormat: CalendarFormat.month,
			headerStyle: HeaderStyle(
				centerHeaderTitle: true,
				formatButtonVisible: false
			),
			calendarStyle: CalendarStyle(
				contentPadding: EdgeInsets.all(5.0)
			),
			events: events,
			onDaySelected: onDaySelected,
			onCalendarCreated: onCalendarCreated,
			onVisibleDaysChanged: onVisibleDaysChanged,
			builders: builders
	);
}

Widget buildTableCalendarCell(DateTime date, Color seletedColor, {bool isCellSelected = false}) {
	return Container(
		margin: const EdgeInsets.all(4.0),
		decoration: BoxDecoration(
			shape: BoxShape.circle,
			color: seletedColor,
			border: isCellSelected ? Border.all(color: Colors.transparent, width: 0) : Border.all(color: Colors.grey[400], width: 1.0),
			boxShadow: [
				if(isCellSelected)
					BoxShadow(color: Colors.black26, blurRadius: 8.0)
			]
		),
		width: 100,
		height: 100,
		child: Center(
			child: Text(
				'${date.day}',
				textAlign: TextAlign.start,
				style: isCellSelected ?
					TextStyle().copyWith(fontSize: 17.0, color: Colors.white, fontWeight: FontWeight.bold)
					: TextStyle().copyWith(fontSize: 15.0)
			)
		)
	);
}

Widget buildMarker({Set<Color> colorSet, List<Color> colorList}) {
	return Positioned(
		left: 6.0,
		right: 6.0,
		bottom: 0,
		child: Wrap(
			alignment: WrapAlignment.center,
			spacing: 2.0,
			children: (colorSet != null ? colorSet : colorList).take(4).map((marker) => Badge(
				badgeColor: marker,
				elevation: 0,
				padding: EdgeInsets.all(3.6),
				animationType: BadgeAnimationType.scale
			)).toList()
		)
	);
}
