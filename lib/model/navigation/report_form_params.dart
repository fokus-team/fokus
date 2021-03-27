// @dart = 2.10
import 'package:fokus/model/ui/task/ui_task_report.dart';

class ReportFormParams {
	final UITaskReport report;
	final Future Function(UITaskReportMark, String) saveCallback;

  ReportFormParams({this.report, this.saveCallback});
}
