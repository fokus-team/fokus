import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';

Duration sumDurations(List<DateSpan<TimeDate>> durations, [bool limitToOneDay = true]) {
	if (durations == null || durations.isEmpty)
		return Duration();
	var sum = durations.sublist(0, durations.length - 1).fold<Duration>(Duration(), (sum, span) => sum + span.to.difference(span.from));
	var midnight = TimeDate(durations.last.from.year, durations.last.from.month, durations.last.from.day + 1);
	var lastSpanEnd = durations.last.to ?? (limitToOneDay ? midnight : TimeDate.now());
	return sum + lastSpanEnd.difference(durations.last.from);
}

String formatDuration(Duration duration) {
	String formatPart(int number, bool firstPart, [bool lastPart = false]) {
		var value = '$number';
		if (!firstPart)
			value = ('0' * (2 - value.length)) + value;
		if (!lastPart)
			value += ':';
		return value;
	}
	var string = '';
	if (duration.inHours > 0)
		string += formatPart(duration.inHours, true);
	if (duration.inMinutes > 0 || string.isNotEmpty)
		string += formatPart(duration.inMinutes.remainder(60), string.isEmpty);
	string += formatPart(duration.inSeconds.remainder(60), string.isEmpty, true);
	if (string.length <= 2)
		string += 's';
	return string;
}

bool isInProgress(List<DateSpan<TimeDate>> durations) {
	return durations != null && durations.length > 0 && durations.last.to == null;
}
