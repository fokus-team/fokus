import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/logic/child_plans/child_plans_cubit.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/app_header.dart';

class ChildPanelPage extends StatefulWidget {
	@override
	_ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					ChildCustomHeader(),
					CubitBuilder<ChildPlansCubit, ChildPlansState>(
						cubit: CubitProvider.of<ChildPlansCubit>(context),
						builder: (context, state) {
							if (state is ChildPlansLoadSuccess)
								return Flexible(
									child: ListView(
										children: state.plans.map((plan) => Text(plan.print(context))).toList(),
									),
								);
							return Expanded(child: Center(child: CircularProgressIndicator()));
						},
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0)
		);
	}
}
