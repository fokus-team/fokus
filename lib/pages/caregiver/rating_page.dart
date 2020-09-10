import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/task/ui_task.dart';
import 'package:fokus/model/ui/task/ui_task_report.dart';
import 'package:fokus/model/ui/user/ui_child.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/cards/report_card.dart';
import 'package:fokus/widgets/general/app_hero.dart';

class CaregiverRatingPage extends StatefulWidget {
  @override
  _CaregiverRatingPageState createState() => new _CaregiverRatingPageState();
}

class _CaregiverRatingPageState extends State<CaregiverRatingPage> {
	static const String _pageKey = 'page.caregiverSection.rating';
	CarouselController _carouselController;
	int _currentRaport = 0;

	// Mock for children task reports
	List<UITaskReport> reports = [
		UITaskReport(
			planName: "Sprzątanie pokoju",
			taskDate: TimeDate(2020, 09, 06, 20, 02),
			task: UITask(
				name: "Odkurz podłogę",
				points: UIPoints(
					quantity: 2,
					title: "Super Punkty",
					type: CurrencyType.emerald
				),
				timer: 60
			),
			child: UIChild(Mongo.ObjectId.fromHexString('6ba8348b71097ab3a63d8edc'), 'Jagoda', avatar: 29),
			taskTimer: 40,
			breakCount: 1,
			breakTimer: 10,
		),
		UITaskReport(
			planName: "Pakowanie tornistra",
			taskDate: TimeDate(2020, 09, 07, 17, 20),
			task: UITask(
				name: "Przygotuj książki i zeszyty na kolejny dzień według planu zajęć",
				points: UIPoints(
					quantity: 50,
					title: "Punkty",
					type: CurrencyType.diamond
				),
				timer: 120
			),
			child: UIChild(Mongo.ObjectId.fromHexString('6ba8348b71097ab3a63d8edb'), 'Maciek', avatar: 13),
			taskTimer: 65,
			breakCount: 0,
			breakTimer: 0,
			ratingMark: UITaskReportMark.rejected
		),
		UITaskReport(
			planName: "Pakowanie tornistra",
			taskDate: TimeDate(2020, 09, 07, 17, 50),
			task: UITask(
				name: "Oddaj strój na WF do prania",
				points: UIPoints(
					quantity: 30,
					title: "Punkty",
					type: CurrencyType.diamond
				),
				timer: 2650
			),
			child: UIChild(Mongo.ObjectId.fromHexString('6ba8348b71097ab3a63d8edb'), 'Maciek', avatar: 13),
			taskTimer: 20,
			breakCount: 1,
			breakTimer: 4,
			ratingMark: UITaskReportMark.rated4
		),
		UITaskReport(
			planName: "Zajęcia z rysunku",
			taskDate: TimeDate(2020, 09, 07, 17, 20),
			task: UITask(
				name: "Odrobienie pracy domowej",
				points: UIPoints(
					quantity: 25,
					title: "Punkty",
					type: CurrencyType.diamond
				),
				timer: 120
			),
			child: UIChild(Mongo.ObjectId.fromHexString('6ba8348b71097ab3a63d8edd'), 'Ninja', avatar: 8),
			taskTimer: 110,
			breakCount: 0,
			breakTimer: 0,
		)
	];

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
				elevation: 0.0
			),
			body: Column(
				mainAxisSize: reports.isNotEmpty ? MainAxisSize.min : MainAxisSize.max,
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					reports.isNotEmpty ?
						Expanded(child: _buildCarousel())
						: AppHero(
							title: AppLocales.of(context).translate('$_pageKey.content.noTasksToRate'),
							color: Colors.white,
							icon: Icons.done,
							dense: true
						)
				]
			)
		);
	}

	Widget _buildCarousel() {
		int notRatedCount = reports.where((element) => element.ratingMark == UITaskReportMark.notRated).length;
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
									child: Wrap(
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
								tag: report.task.id.toString() + report.taskDate.toString(),
								child: ReportCard(report: report)
							)
						).toList()
					)
				)
			]
		);
	}

}
