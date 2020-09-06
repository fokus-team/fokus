import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';

class LargeTimer extends StatelessWidget {
	final Color textColor;
	final String title;
	final CrossAxisAlignment align;

	LargeTimer({this.textColor,  this.title, this.align = CrossAxisAlignment.start});

	@override
	Widget build(BuildContext context) {
		return BlocBuilder<TimerCubit, TimerState>(
			builder: (context, state) {
				return Column(
					mainAxisAlignment: MainAxisAlignment.start,
					crossAxisAlignment: align,
					children: [
						Text(
							AppLocales.of(context).translate(title),
							style: Theme.of(context).textTheme.headline3.copyWith(color: textColor),
						),
						Text(
							formatDuration(Duration(seconds: state.value)),
							style: Theme.of(context).textTheme.headline1.copyWith(color: textColor),
						)
					],
				);
			},
		);
	}
}
