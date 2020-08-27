import 'dart:developer';

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
					Expanded(
					  child: FlipCard(
					  	front: Container(
					  		decoration: BoxDecoration(
					  			color: Colors.white
					  		),
					  		child: Stack(
					  		  children: [
										Padding(
											padding: const EdgeInsets.all(14.0),
											child: Align(
												alignment: Alignment.topRight,
												child: IconButton(
													icon: Icon(Icons.cancel, color: Colors.red,),
													onPressed: null,
												),
											),
										),
										Column(
											mainAxisAlignment: MainAxisAlignment.spaceEvenly,
											children: [
												SingleChildScrollView(
													child: Column(
														children: [
															Text("xd"),
															Text("xDddd"),
														]
													),
												),
												Row(
													mainAxisAlignment: MainAxisAlignment.spaceEvenly,
													children: [
														SquareButton(
															'$_pageKey.content.reject',
															Icons.cancel,
															() => log("XD")
														),
														SquareButton(
															'$_pageKey.content.reject',
															Icons.hourglass_full,
															null,
															isVertical: true,
														)
													],
												),
											]
										),
										Align(
											alignment: FractionalOffset.bottomCenter,
										  child: Container(
										  	decoration: AppBoxProperties.elevatedContainer.copyWith(color: Colors.white),
										  	height: 84,
										  ),
										),
										Positioned(
											right: 0,
											left: 0,
											bottom: 55,
											child: Row(
												mainAxisAlignment: MainAxisAlignment.spaceEvenly,
												children: [
													SquareButton(
														'$_pageKey.content.reject',
														Icons.cancel,
														() => log("XD"),
														backgroundColor: Colors.red,
													),
													SquareButton(
														'$_pageKey.content.break',
														Icons.hourglass_empty,
														() => log("XD"),
														backgroundColor: Colors.blue,
													),
													SquareButton(
														'$_pageKey.content.done',
														Icons.check,
															() => log("XD"),
														backgroundColor: Colors.green,
													)
												],
											),
										)
									]
					  		),
					  	),
					  	back: Container(

					  	),
					  ),
					)
				]
			)
		);
  }
}
