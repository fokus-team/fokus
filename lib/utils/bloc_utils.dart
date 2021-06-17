import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget withCubit<CubitType extends Cubit>(Widget widget, CubitType cubit) {
	return BlocProvider(
		create: (context) => cubit,
		child: widget,
	);
}

Widget forwardCubit<CubitType extends Cubit>(Widget widget, CubitType cubit) {
	return BlocProvider.value(
		value: cubit,
		child: widget,
	);
}

Widget tryForwardCubit<CubitType extends Cubit>(Widget widget, BuildContext context) {
	CubitType cubit;
	try {
		cubit = BlocProvider.of<CubitType>(context);
// ignore: avoid_catching_errors
	} on Error {
		return widget;
	}
	return forwardCubit<CubitType>(widget, cubit);
}
