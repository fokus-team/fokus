import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';

class LargeTimer extends StatelessWidget {
	final Color textColor;
	final String title;
	final CrossAxisAlignment align;
	final int value;

	LargeTimer({this.textColor,  this.title, this.align = CrossAxisAlignment.start, this.value});

	@override
	Widget build(BuildContext context) {
		if(value == null) return BlocBuilder<TimerCubit, TimerState>(
			builder: (context, state) {
				return timeUI(context, state: state);
			},
		);
		return timeUI(context, value: value);
	}

	Widget timeUI(BuildContext context, {state, int value}) {
		return Column(
			mainAxisAlignment: MainAxisAlignment.start,
			crossAxisAlignment: align,
			children: [
				Text(
					AppLocales.of(context).translate(title),
					style: Theme.of(context).textTheme.headline3.copyWith(color: textColor),
				),
				Text(
					formatDuration(Duration(seconds: value != null ? value : state.value)),
					style: Theme.of(context).textTheme.headline1.copyWith(color: textColor),
				)
			],
		);
	}
}
