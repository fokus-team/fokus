import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/common/timer/timer_cubit.dart';
import '../services/app_locales.dart';
import '../utils/duration_utils.dart';

class LargeTimer extends StatelessWidget {
	final Color textColor;
	final String title;
	final CrossAxisAlignment align;

	LargeTimer({required this.textColor, required this.title, this.align = CrossAxisAlignment.start});

	@override
	Widget build(BuildContext context) {
	return BlocBuilder<TimerCubit, TimerState>(
			builder: (context, state) {
				return timeUI(context, state.value);
			},
		);
	}

	Widget timeUI(BuildContext context, int value) {
		return Column(
			mainAxisAlignment: MainAxisAlignment.start,
			crossAxisAlignment: align,
			children: [
				Text(
					AppLocales.of(context).translate(title),
					style: Theme.of(context).textTheme.headline3?.copyWith(color: textColor),
					softWrap: false,
					overflow: TextOverflow.fade
				),
				Text(
					formatDuration(Duration(seconds: value)),
					style: Theme.of(context).textTheme.headline1?.copyWith(color: textColor),
				)
			],
		);
	}
}
