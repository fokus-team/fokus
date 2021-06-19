import 'package:meta/meta.dart';

abstract class LoadableCubit {
	@protected
	Future loadData();
}
