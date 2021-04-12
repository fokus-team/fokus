import 'package:fokus/model/ui/task/ui_task_report.dart';

class ReportFormParams {
	final UITaskReport report;
	final Future Function(UITaskReportMark, String) saveCallback;

  ReportFormParams({required this.report, required this.saveCallback});
}
