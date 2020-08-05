import 'package:cubit/cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

Widget navigateOnState<Cubit extends CubitStream<State>, State, NavState>({Widget child, Function(NavigatorState) navigation}) {
	return CubitListener<Cubit, State>(
		listener: (context, state) => state is NavState ? navigation(Navigator.of(context)) : {},
		child: child
	);
}
