import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/caregiver/tasks_evaluation/tasks_evaluation_cubit.dart';
import 'package:fokus/model/ui/task/ui_task_report.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/forms/report_form.dart';
import 'package:fokus/widgets/general/app_avatar.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatefulWidget {
	final UITaskReport report;
	final bool hideBottomBar;

	ReportCard({@required this.report, this.hideBottomBar = false});

  @override
  _ReportCardState createState() => new _ReportCardState();
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
						widget.report.task.name,
						maxLines: 3,
						overflow: TextOverflow.ellipsis,
						style: Theme.of(context).textTheme.headline3
					),
					SizedBox(height: 6.0),
					Divider(color: Colors.grey[400]),
					Tooltip(
						message: AppLocales.of(context).translate('$_pageKey.raportCard.carriedOutBy'),
						child: ListTile(
							leading: AppAvatar(widget.report.child.avatar, size: 48.0),
							title: Text(widget.report.child.name),
							visualDensity: VisualDensity.compact
						)
					),
					Divider(color: Colors.grey[400]),
					_buildReportTile(
						Icons.event,
						Text(
							widget.report.task.duration.last.to.toAppString(DateFormat.yMEd(AppLocales.of(context).locale.toString()).add_jm()),
							softWrap: false,
							overflow: TextOverflow.fade,
						),
						AppLocales.of(context).translate('$_pageKey.raportCard.raportDate')
					),
					_buildReportTile(
						Icons.timer,
						Text(
							AppLocales.of(context).translate('$_pageKey.raportCard.timeFormat', {
								'HOURS_NUM': sumDurations(widget.report.task.duration).inHours,
								'MINUTES_NUM': sumDurations(widget.report.task.duration).inMinutes.remainder(60),
								'SECONDS_NUM': sumDurations(widget.report.task.duration).inSeconds.remainder(60)
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
								text: AppLocales.of(context).translate('$_pageKey.raportCard.breakCount', {
									'BREAKS_NUM': widget.report.task.breaks.length
								}) + ' ',
								style: Theme.of(context).textTheme.bodyText2,
								children: [
									if(widget.report.task.breaks.length > 0)
										TextSpan(
											text: '(${AppLocales.of(context).translate('$_pageKey.raportCard.totalBreakTime')}: ' +
												AppLocales.of(context).translate('$_pageKey.raportCard.timeFormat', {
													'HOURS_NUM': sumDurations(widget.report.task.breaks).inHours,
													'MINUTES_NUM': sumDurations(widget.report.task.breaks).inMinutes.remainder(60),
													'SECONDS_NUM': sumDurations(widget.report.task.breaks).inSeconds.remainder(60)
												}) + ')',
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

	void updateReports(UITaskReportMark mark, String comment) {
		setState(() {
			widget.report.ratingMark = mark;
			widget.report.ratingComment = comment;
		});
		BlocProvider.of<TasksEvaluationCubit>(context).rateTask(widget.report);
	}

	Widget _buildBottomBar(BuildContext context) {
		bool isNotRated = widget.report.ratingMark.value == null;
		bool isRejected = widget.report.ratingMark.value == 0;

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
						RaisedButton.icon(
							color: AppColors.caregiverButtonColor,
							materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
							padding: EdgeInsets.symmetric(vertical: 8.0),
							colorBrightness: Brightness.dark,
							onPressed: () async {
								Navigator.of(context).push(MaterialPageRoute(
									builder: (context) => ReportForm(
										report: widget.report,
										saveCallback: updateReports
									)
								));
							},
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
		else if(widget.report.task.points != null)
			return AppLocales.of(context).translate('$_pageKey.raportCard.ratedOnHint',
				{'POINTS_NUM': (TasksEvaluationCubit.getPointsAwarded(widget.report.ratingMark.value, widget.report.task.points.quantity).toString())});
		else
			return AppLocales.of(context).translate('$_pageKey.raportCard.ratedOnLabel',
				{'STARS_NUM': widget.report.ratingMark.value.toString()});
  }
}
