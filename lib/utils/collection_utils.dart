Map<Key, List<Val>> groupBy<Key, Val>(Iterable<Val> values, Key Function(Val) key) {
	var map = <Key, List<Val>>{};
	for (var element in values) {
		(map[key(element)] ??= []).add(element);
	}
	return map;
}
