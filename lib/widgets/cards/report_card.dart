import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../logic/caregiver/tasks_evaluation_cubit.dart';
import '../../model/navigation/child_dashboard_params.dart';
import '../../model/navigation/report_form_params.dart';
import '../../model/ui/app_page.dart';
import '../../model/ui/plan/ui_task_report.dart';
import '../../services/app_locales.dart';
import '../../utils/duration_utils.dart';
import '../../utils/ui/theme_config.dart';
import '../general/app_avatar.dart';

class ReportCard extends StatefulWidget {
	final UITaskReport report;
	final bool hideBottomBar;

	ReportCard({required this.report, this.hideBottomBar = false});

  @override
  _ReportCardState createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
	static const String _pageKey = 'page.caregiverSection.rating.content';
	final Radius defaultRadius = Radius.circular(AppBoxProperties.roundedCornersRadius);

  @override
  Widget build(BuildContext context) {
		return Material(
			type: MaterialType.transparency,
			child: SingleChildScrollView(
				clipBehavior: Clip.none,
				child: Column(
					children: [
						Container(
							decoration: AppBoxProperties.elevatedContainer.copyWith(
								borderRadius: widget.hideBottomBar ?
									BorderRadius.all(defaultRadius)
									: BorderRadius.vertical(top: defaultRadius)
							),
							child: _buildReportDetails(context)
						),
						if(!widget.hideBottomBar)
							_buildBottomBar(context)
					]
				)
			)
		);
  }

	Widget _buildReportTile(IconData icon, Widget content, String tooltip) {
		return Tooltip(
			message: tooltip,
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					Padding(
						padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0).copyWith(right: 16.0),
						child: Icon(icon, size: 28, color: Colors.grey[600])
					),
					Expanded(child: content)
				]
			)
		);
	}
	
	Widget _buildReportDetails(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), 
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						widget.report.planName,
						maxLines: 1,
						overflow: TextOverflow.ellipsis,
						style: TextStyle(color: AppColors.mediumTextColor, fontSize: 15.0)
					),
					Text(
						widget.report.uiTask.task.name!,
						maxLines: 3,
						overflow: TextOverflow.ellipsis,
						style: Theme.of(context).textTheme.headline3
					),
					SizedBox(height: 6.0),
					Divider(color: Colors.grey[400]),
					Tooltip(
						message: AppLocales.of(context).translate('$_pageKey.raportCard.carriedOutBy'),
						child: ListTile(
							onTap: () => Navigator.of(context).pushNamed(
								AppPage.caregiverChildDashboard.name, 
								arguments: ChildDashboardParams(childCard: widget.report.childCard),
							),
							leading: AppAvatar(widget.report.childCard.child.avatar, size: 48.0),
							title: Text(widget.report.childCard.child.name!),
							visualDensity: VisualDensity.compact
						)
					),
					Divider(color: Colors.grey[400]),
					_buildReportTile(
						Icons.event,
						Text(
							widget.report.uiTask.instance.duration!.last.to!.toAppString(DateFormat.yMEd(AppLocales.of(context).locale.toString()).add_jm()),
							softWrap: false,
							overflow: TextOverflow.fade,
						),
						AppLocales.of(context).translate('$_pageKey.raportCard.raportDate')
					),
					_buildReportTile(
						Icons.timer,
						Text(
							AppLocales.of(context).translate('$_pageKey.raportCard.timeFormat', {
								'HOURS_NUM': sumDurations(widget.report.uiTask.instance.duration).inHours,
								'MINUTES_NUM': sumDurations(widget.report.uiTask.instance.duration).inMinutes.remainder(60),
								'SECONDS_NUM': sumDurations(widget.report.uiTask.instance.duration).inSeconds.remainder(60)
							}),
							softWrap: false,
							overflow: TextOverflow.fade,
						),
						AppLocales.of(context).translate('$_pageKey.raportCard.raportTime')
					),
					_buildReportTile(
						Icons.notifications_active,
						RichText(
							softWrap: false,
							overflow: TextOverflow.fade,
							text: TextSpan(
								text: '${AppLocales.of(context).translate('$_pageKey.raportCard.breakCount', {
									'BREAKS_NUM': widget.report.uiTask.instance.breaks!.length
								})} ',
								style: Theme.of(context).textTheme.bodyText2,
								children: [
									if(widget.report.uiTask.instance.breaks!.isNotEmpty)
										TextSpan(
											text: '(${AppLocales.of(context).translate('$_pageKey.raportCard.totalBreakTime')}: '
													'${AppLocales.of(context).translate('$_pageKey.raportCard.timeFormat', {
													'HOURS_NUM': sumDurations(widget.report.uiTask.instance.breaks).inHours,
													'MINUTES_NUM': sumDurations(widget.report.uiTask.instance.breaks).inMinutes.remainder(60),
													'SECONDS_NUM': sumDurations(widget.report.uiTask.instance.breaks).inSeconds.remainder(60)
												})})',
											style: TextStyle(color: AppColors.mediumTextColor, fontSize: 13.0)
										)
								]
							)
						),
						AppLocales.of(context).translate('$_pageKey.raportCard.raportBreaks')
					)
				]
			)
		);
	}

	Future updateReports(UITaskReportMark mark, String comment) {
		setState(() {
			widget.report.ratingMark = mark;
			widget.report.ratingComment = comment;
		});
		return BlocProvider.of<TasksEvaluationCubit>(context).rateTask(widget.report);
	}

	Widget _buildBottomBar(BuildContext context) {
		var isNotRated = widget.report.ratingMark.value == null;
		var isRejected = widget.report.ratingMark.value == 0;

		return Container(
			width: double.infinity,
			margin: EdgeInsets.only(bottom: 20.0),
			padding: EdgeInsets.symmetric(vertical: isNotRated ? 12.0 : 4.0, horizontal: AppBoxProperties.screenEdgePadding),
			decoration: BoxDecoration(
				color: isNotRated ? Colors.grey[200] : (isRejected ? Colors.red[100] : Colors.green[100]),
				borderRadius: BorderRadius.vertical(bottom: defaultRadius)
			),
			child: isNotRated ?
				Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						ElevatedButton.icon(
							style: ElevatedButton.styleFrom(
								primary: AppColors.caregiverButtonColor,
								padding: EdgeInsets.symmetric(vertical: 8.0),
							),
							onPressed: () => Navigator.of(context).pushNamed(AppPage.caregiverReportForm.name, arguments: ReportFormParams(
								report: widget.report,
								saveCallback: updateReports
							)),
							icon: Icon(Icons.rate_review),
							label: Text(AppLocales.of(context).translate('$_pageKey.rateTaskButton'))
						)
					]
				)
				: ListTile(
					leading: Icon(
						isRejected ? Icons.block : Icons.done,
						color: isRejected ? Colors.red : Colors.green,
						size: 32.0
					),
					title: Text(
						isRejected ?
							AppLocales.of(context).translate('$_pageKey.raportCard.rejectedLabel')
							: AppLocales.of(context).translate('$_pageKey.raportCard.ratedOnLabel', {'STARS_NUM': widget.report.ratingMark.value.toString()})
					),
					subtitle: Text(_getSubtitle()),
					visualDensity: VisualDensity.compact,
					contentPadding: EdgeInsets.zero
				)
		);
	}

	String _getSubtitle() {
  	if(widget.report.ratingMark.value == 0)
  		return AppLocales.of(context).translate('$_pageKey.raportCard.rejectedHint');
		else if(widget.report.uiTask.task.points != null)
			return AppLocales.of(context).translate('$_pageKey.raportCard.ratedOnHint',
				{'POINTS_NUM': (TasksEvaluationCubit.getPointsAwarded(widget.report.ratingMark.value!, widget.report.uiTask.task.points!.quantity!).toString())});
		else
			return AppLocales.of(context).translate('$_pageKey.raportCard.ratedOnLabel',
				{'STARS_NUM': widget.report.ratingMark.value.toString()});
  }
}
