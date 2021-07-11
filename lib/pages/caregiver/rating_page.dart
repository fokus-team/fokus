import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:round_spot/round_spot.dart' as rs;

import '../../logic/caregiver/tasks_evaluation_cubit.dart';
import '../../model/ui/plan/ui_task_report.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/theme_config.dart';
import '../../widgets/buttons/help_icon_button.dart';
import '../../widgets/cards/report_card.dart';
import '../../widgets/general/app_hero.dart';
import '../../widgets/stateful_bloc_builder.dart';


class CaregiverRatingPage extends StatefulWidget {
  @override
  _CaregiverRatingPageState createState() => _CaregiverRatingPageState();
}

class _CaregiverRatingPageState extends State<CaregiverRatingPage> {
	static const String _pageKey = 'page.caregiverSection.rating';
	late CarouselController _carouselController;
	int _currentRaport = 0;

	@override
  void initState() {
    super.initState();
		_carouselController = CarouselController();
  }


  @override
  Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.caregiverBackgroundColor,
			appBar: AppBar(
				title: Text(AppLocales.of(context).translate('$_pageKey.header.title')),
				backgroundColor: Colors.transparent,
				elevation: 0.0,
				actions: <Widget>[
					HelpIconButton(helpPage: 'rating')
				]
			),
			body: StatefulBlocBuilder<TasksEvaluationCubit, TasksEvaluationData>(
				builder: (context, state) {
					return Column(
						mainAxisSize: state.data!.reports.isNotEmpty ? MainAxisSize.min : MainAxisSize.max,
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [state.data!.reports.isNotEmpty ? Expanded(child: _buildCarousel(state.data!.reports)) :
							AppHero(
							  title: AppLocales.of(context).translate('$_pageKey.content.noTasksToRate'),
							  color: Colors.white,
							  icon: Icons.done,
							  dense: true
						  )
				    ]
					);
				}
			)
		);
	}

	Widget _buildCarousel(List<UITaskReport> reports) {
		var notRatedCount = reports.where((element) => element.ratingMark == UITaskReportMark.notRated).length;
		return Column(
			children: [
				SizedBox(height: 8.0),
				Text(
					AppLocales.of(context).translate('$_pageKey.content.notRatedTasksLeft', {
						'TASKS_NUM': notRatedCount.toString()
					}),
					style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
				),
				SizedBox(height: 4.0),
				if(reports.length > 1)
					Row(
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [
							IconButton(
								icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
								onPressed: () => _carouselController.previousPage(),
								tooltip: AppLocales.of(context).translate('$_pageKey.content.previousTaskButton')
							),
							ConstrainedBox(
								constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*.70),
								child: Padding(
									padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
									child: reports.length <= 8 ? Wrap(
										alignment: WrapAlignment.center,
										children: List.generate(reports.length, (index) => index).map((index) =>
											Container(
												margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
												child: Icon(
													reports[index].ratingMark != UITaskReportMark.notRated ? Icons.check_circle : Icons.lens,
													color: _currentRaport == index ? Colors.white : Colors.white38,
													size: 16.0
												)
											)
										).toList()
									)
									: Text('${_currentRaport+1} / ${reports.length}', style: TextStyle(color: Colors.white, fontSize: 17.0))
								)
							),
							IconButton(
								icon: Icon(Icons.chevron_right, color: Colors.white, size: 30),
								onPressed: () => _carouselController.nextPage(),
								tooltip: AppLocales.of(context).translate('$_pageKey.content.nextTaskButton')
							)
						]
					),
				SizedBox(height: 8.0),
				Expanded(
					child: rs.Detector.custom(
						areaID: 'rating-cards',
						scrollAxis: Axis.horizontal,
						child: CarouselSlider(
							options: CarouselOptions(
								enlargeCenterPage: true,
								disableCenter: true,
								enableInfiniteScroll: false,
								onPageChanged: (index, reason) {
									setState(() {_currentRaport = index; });
								}
							),
							carouselController: _carouselController,
							items: reports.map((report) =>
								Hero(
									tag: report.uiTask.instance.id.toString() + report.uiTask.instance.duration!.last.to.toString(),
									child: ReportCard(report: report)
								)
							).toList()
						),
					)
				)
			]
		);
	}
}
