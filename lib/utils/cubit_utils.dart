import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget navigateOnState<CubitType extends Cubit<State>, State, NavState>({Widget child, Function(NavigatorState) navigation}) {
	return BlocListener<CubitType, State>(
		listener: (context, state) => state is NavState ? navigation(Navigator.of(context)) : {},
		child: child
	);
}
