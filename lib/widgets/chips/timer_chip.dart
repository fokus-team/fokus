// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/common/timer/timer_cubit.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';

class TimerChip extends StatelessWidget {
	final Color color;
	final IconData icon;

	TimerChip({this.color, this.icon = Icons.timer});

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
