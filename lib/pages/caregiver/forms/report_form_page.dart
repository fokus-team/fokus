import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:round_spot/round_spot.dart' as round_spot;

import '../../../logic/caregiver/tasks_evaluation_cubit.dart';
import '../../../model/navigation/report_form_params.dart';
import '../../../model/ui/plan/ui_task_report.dart';
import '../../../services/app_locales.dart';
import '../../../utils/ui/dialog_utils.dart';
import '../../../utils/ui/form_config.dart';
import '../../../utils/ui/theme_config.dart';
import '../../../widgets/cards/report_card.dart';
import '../../../widgets/chips/attribute_chip.dart';

class ReportFormPage extends StatefulWidget {
	final UITaskReport report;
	final Future Function(UITaskReportMark, String) saveCallback;

	ReportFormPage(ReportFormParams params) : report = params.report, saveCallback = params.saveCallback;

	@override
	_ReportFormPageState createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
	static const String _pageKey = 'page.caregiverSection.rating.content.form';
	final double customBottomBarHeight = 40.0;

	late GlobalKey<FormState> reportFormKey;
	bool isDataChanged = false;

	late FocusNode _focusNodeComment;
	final TextEditingController _commentController = TextEditingController();
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
			onWillPop: () async {
				var ret = await showExitFormDialog(context, true, isDataChanged);
				if(ret == null || !ret) return false;
				else return true;
			},
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
					TextButton(
						onPressed: () async {
							await widget.saveCallback(isRejected ? UITaskReportMark.rejected : mark, _commentController.value.text);
							Navigator.of(context).pop();
						},
						child: Text(
							AppLocales.of(context).translate('actions.confirm'),
							style: Theme.of(context).textTheme.button?.copyWith(color: AppColors.mainBackgroundColor)
						)
					)
				]
			)
		);
	}

	Widget _buildForm() {
		return round_spot.Detector(
			areaID: 'rating-form',
		  child: SingleChildScrollView(
		  	clipBehavior: Clip.none,
		  	child: Column(
		  		children: [
		  			Container(
		  				margin: EdgeInsets.all(AppBoxProperties.screenEdgePadding),
		  				child: Hero(
		  					tag: widget.report.uiTask.instance.id.toString() + widget.report.uiTask.instance.duration!.last.to.toString(),
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
		  ),
		);
	}

	Widget _getPointsAssigned() {
		var taskPoints = widget.report.uiTask.task.points!;
		var totalPoints = taskPoints.quantity!;
		var points = TasksEvaluationCubit.getPointsAwarded(totalPoints, mark.value!);
		return AttributeChip.withCurrency(
			currencyType: taskPoints.type!,
			content: '$points / $totalPoints',
			tooltip: taskPoints.name
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
								initialRating: mark.value?.toDouble() ?? 3,
								itemCount: 5,
								itemSize: 50.0,
								unratedColor: Colors.grey[300],
								tapOnlyMode: true,
								glow: false,
								itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
								onRatingUpdate: (val) {
									FocusManager.instance.primaryFocus?.unfocus();
									setState((){ mark = UITaskReportMark.values.firstWhere((element) => element.value == val.toInt()); });
								},
							),
							Text(
								'${AppLocales.of(context).translate('$_pageKey.ratingLabel')}: ${mark.value.toString()}/5 ('
										'${AppLocales.of(context).translate('$_pageKey.ratingLevels.${mark.toString().split('.').last}')})',
								style: TextStyle(fontWeight: FontWeight.bold)
							),
							widget.report.uiTask.task.points != null ? Padding(
								padding: EdgeInsets.only(top: 12.0),
								child: Wrap(
									alignment: WrapAlignment.center,
									crossAxisAlignment: WrapCrossAlignment.center,
									spacing: 2.0,
									children: [
										Text(
											'${AppLocales.of(context).translate('$_pageKey.pointsAssigned')}: ',
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
				isRejected = val!;
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
