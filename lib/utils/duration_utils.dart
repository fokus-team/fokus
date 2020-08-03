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
