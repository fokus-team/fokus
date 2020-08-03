import 'package:meta/meta.dart';

enum CountDirection {
	up, down
}

class Ticker {
	Stream<int> tick({@required int initialValue, @required CountDirection direction}) {
	  return Stream.periodic(Duration(seconds: 1), (x) => direction == CountDirection.up ? initialValue + x + 1 : initialValue - x - 1);
	}
}
