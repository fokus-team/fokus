import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';

class TimerChip extends StatelessWidget {
	final Color color;

	TimerChip({this.color});

	@override
	Widget build(BuildContext context) {
		return BlocBuilder<TimerCubit, TimerState>(
			cubit: BlocProvider.of<TimerCubit>(context),
			builder: (context, state) {
				return AttributeChip.withIcon(
					icon: Icons.timer,
					color: color,
					content: formatDuration(Duration(seconds: state.value))
				);
			},
		);
	}
}
