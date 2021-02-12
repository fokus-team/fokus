import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fokus/logic/caregiver/tasks_evaluation/tasks_evaluation_cubit.dart';

import 'package:fokus/model/ui/task/ui_task_report.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/form_config.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/cards/report_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';

class ReportForm extends StatefulWidget {
	final UITaskReport report;
	final Function(UITaskReportMark, String) saveCallback;

	ReportForm({@required this.report, @required this.saveCallback});

	@override
	_ReportFormState createState() => new _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
	static const String _pageKey = 'page.caregiverSection.rating.content.form';
	final double customBottomBarHeight = 40.0;

	GlobalKey<FormState> reportFormKey;
	bool isDataChanged = false;

	FocusNode _focusNodeComment;
	TextEditingController _commentController = TextEditingController();
	UITaskReportMark mark = UITaskReportMark.rated3;
	bool isRejected = false;

	@override
  void initState() {
		reportFormKey = GlobalKey<FormState>();
		_focusNodeComment = FocusNode();
    super.initState();
  }
	
	@override
  void dispose() {
		super.dispose();
		_commentController.dispose();
		_focusNodeComment.dispose();
	}

  @override
  Widget build(BuildContext context) {
		return WillPopScope(
			onWillPop: () => showExitFormDialog(context, true, isDataChanged),
			child: Scaffold(
				appBar: AppBar(
					title: Text(AppLocales.of(context).translate('page.caregiverSection.rating.content.rateTaskButton')),
					backgroundColor: AppColors.formColor,
				),
				body: Stack(
					children: [
						Positioned.fill(
							bottom: AppBoxProperties.standardBottomNavHeight,
							child: Form(
								key: reportFormKey,
								child: Material(
									child: _buildForm()
								)
							)
						),
						Positioned.fill(
							top: null,
							child: buildBottomNavigation(context)
						)
					]
				)
			)
		);
	}
	
	Widget buildBottomNavigation(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
			decoration: AppBoxProperties.elevatedContainer,
			height: AppBoxProperties.standardBottomNavHeight,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.end,
				children: <Widget>[
					SizedBox.shrink(),
					FlatButton(
						onPressed: () {
							widget.saveCallback(isRejected ? UITaskReportMark.rejected : mark, _commentController.value.text);
							Navigator.of(context).pop();
						},
						child: Text(
							AppLocales.of(context).translate('actions.confirm'),
							style: Theme.of(context).textTheme.button.copyWith(color: AppColors.mainBackgroundColor)
						)
					)
				]
			)
		);
	}

	Widget _buildForm() {
		return SingleChildScrollView(
			clipBehavior: Clip.none,
			child: Column(
				children: [
					Container(
						margin: EdgeInsets.all(AppBoxProperties.screenEdgePadding),
						child: Hero(
							tag: widget.report.task.id.toString() + widget.report.task.duration.last.to.toString(),
							child: ReportCard(report: widget.report, hideBottomBar: true)
						)
					),
					ListView(
						shrinkWrap: true,
						physics: NeverScrollableScrollPhysics(),
						children: <Widget>[
							_buildRateField(),
							_buildRejectField(),
							_buildCommentField(),
							SizedBox(height: 30.0)
						]
					)
				]
			)
		);
	}

	Widget _getPointsAssigned() {
		int totalPoints = widget.report.task.points.quantity;
		int points = TasksEvaluationCubit.getPointsAwarded(totalPoints, mark.value);
		return AttributeChip.withCurrency(
			currencyType: widget.report.task.points.type,
			content: '$points / $totalPoints',
			tooltip: widget.report.task.points.title
		);
	}

	Widget _buildRateField() {
		return AnimatedSwitcher(
			duration: Duration(milliseconds: 250),
			transitionBuilder: (child, animation) {
				return SizeTransition(
					sizeFactor: animation,
					axis: Axis.vertical,
					child: FadeTransition(
						opacity: animation,
						child: child
					)
				);
			},
			child: isRejected ? 
				SizedBox.shrink()
				: Container(
					width: double.infinity,
					padding: EdgeInsets.only(top: 2.0, bottom: 20.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [
							RatingBar.builder(
								minRating: 0.0,
								maxRating: 5.0,
								initialRating: mark.value.toDouble() ?? 3,
								itemCount: 5,
								itemSize: 50.0,
								unratedColor: Colors.grey[300],
								tapOnlyMode: true,
								glow: false,
								itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
								onRatingUpdate: (val) {
									FocusManager.instance.primaryFocus.unfocus();
									setState((){ mark = UITaskReportMark.values.firstWhere((element) => element.value == val.toInt()); });
								},
							),
							Text(
								'${AppLocales.of(context).translate(_pageKey+'.ratingLabel')}: ${mark.value.toString()}/5 (' + 
								AppLocales.of(context).translate('$_pageKey.ratingLevels.${mark.toString().split('.').last}') + ')',
								style: TextStyle(fontWeight: FontWeight.bold)
							),
							widget.report.task.points != null ? Padding(
								padding: EdgeInsets.only(top: 12.0),
								child: Wrap(
									alignment: WrapAlignment.center,
									crossAxisAlignment: WrapCrossAlignment.center,
									spacing: 2.0,
									children: [
										Text(
											AppLocales.of(context).translate('$_pageKey.pointsAssigned') + ': ',
											style: TextStyle(color: AppColors.mediumTextColor)
										),
										_getPointsAssigned()
									]
								)
							) : SizedBox.shrink()
						]
					)
				)
		);
	}

	Widget _buildRejectField() {
		return CheckboxListTile(
			title: Text(AppLocales.of(context).translate('$_pageKey.markTaskAsNotDone'), style: TextStyle(color: Colors.red)),
			subtitle: Text(AppLocales.of(context).translate('$_pageKey.markTaskAsNotDoneHint')),
			activeColor: Colors.red,
			secondary: Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.block, color: Colors.red)),
			value: isRejected,
			onChanged: (val) => setState(() {
				isRejected = val;
			})
		);
	}

	Widget _buildCommentField() {
		return Padding(
			padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: AppBoxProperties.screenEdgePadding),
			child: TextFormField(
				controller: _commentController,
				decoration: AppFormProperties.longTextFieldDecoration(Icons.description).copyWith(
					labelText: AppLocales.of(context).translate('$_pageKey.rateCommentLabel')
				),
				maxLength: AppFormProperties.longTextFieldMaxLength,
				minLines: AppFormProperties.longTextMinLines,
				maxLines: AppFormProperties.longTextMaxLines,
				textCapitalization: TextCapitalization.sentences,
				onChanged: (val) => setState(() {
					isDataChanged = val.isNotEmpty;
				}),
				focusNode: _focusNodeComment,
				textInputAction: TextInputAction.done,
				onEditingComplete: () {
					_focusNodeComment.unfocus();
				}
			)
		);
	}

}
