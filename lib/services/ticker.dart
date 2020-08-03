import 'package:meta/meta.dart';

enum CountDirection {
	up, down
}

class Ticker {
	Stream<int> tick({@required CountDirection direction, int value}) {
	  return Stream.periodic(Duration(seconds: 1), (x) => direction == CountDirection.up ? value + x + 1 : value - x - 1);
	}
}
