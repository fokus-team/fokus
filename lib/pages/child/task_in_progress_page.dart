import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/buttons/square_button.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';

class ChildTaskInProgressPage extends StatefulWidget {
  @override
  _ChildTaskInProgressPageState createState() => _ChildTaskInProgressPageState();
}

class _ChildTaskInProgressPageState extends State<ChildTaskInProgressPage> {
  final String _pageKey = 'page.childSection.taskInProgress';

  @override
  Widget build(BuildContext context) {
  	return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.widget(
						title: '$_pageKey.header.title',
						appHeaderWidget: ItemCard(
							title: "Sprzątanie pokoju",
							subtitle: "Co każdy poniedziałek, środę, czwartek i piątek",
							isActive: true,
							progressPercentage: 0.4,
							activeProgressBarColor: AppColors.childActionColor,
							chips:
							<Widget>[
								AttributeChip.withIcon(
									icon: Icons.description,
									color: AppColors.childBackgroundColor,
									content: AppLocales.of(context).translate('page.childSection.panel.content.taskProgress', {'NUM_TASKS': 2, 'NUM_ALL_TASKS': 5})
								)
							],
						),
						helpPage: 'plan_info'
					),
					FlipCard(
						front: Container(
							decoration: BoxDecoration(
								color: AppColors.childActionColor
							),
							child: Column(
								children: [
									IconButton(
										icon: Icon(Icons.clear),
										onPressed: null,
									),
									ListView(
										children: [
											Expanded(
												child: Text("xd"),
											),
											Expanded(
												child: Text("xDddd"),
											),
											Row(
												children: [
													SquareButton(
														"xd",
														Icons.clear,
														null
													),
													SquareButton(
														"xd",
														Icons.clear,
														null
													)
												],
											)
										]
									),
									Positioned(
										right: 0,
										left: 0,
										bottom: 0,
										child: Row(
											children: [
												SquareButton(
													"xd",
													Icons.clear,
													null
												),
												SquareButton(
													"xd",
													Icons.clear,
													null
												),
												SquareButton(
													"xd",
													Icons.clear,
													null
												)
											],
										),
									),
								]
							),
						),
						back: Container(

						),
					)
				]
			)
		);
  }
}
