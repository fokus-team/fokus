import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/common/timer/timer_cubit.dart';
import '../../utils/duration_utils.dart';
import 'attribute_chip.dart';

class TimerChip extends StatelessWidget {
	final Color color;
	final IconData icon;

	TimerChip({required this.color, this.icon = Icons.timer});

	@override
	Widget build(BuildContext context) {
		return BlocBuilder<TimerCubit, TimerState>(
			builder: (context, state) {
				return AttributeChip.withIcon(
					icon: icon,
					color: color,
					content: formatDuration(Duration(seconds: state.value))
				);
			},
		);
	}
}
