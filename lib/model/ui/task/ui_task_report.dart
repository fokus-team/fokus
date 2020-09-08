import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/ui/task/ui_task.dart';
import 'package:fokus/model/ui/user/ui_child.dart';

enum UITaskReportMark { notRated, rated5, rated4, rated3, rated2, rated1, rejected }

extension UITaskReportMarkExtension on UITaskReportMark {
  int get value {
    switch (this) {
      case UITaskReportMark.notRated:
        return null;
      case UITaskReportMark.rejected:
        return 0;
      case UITaskReportMark.rated1:
        return 1;
      case UITaskReportMark.rated2:
        return 2;
      case UITaskReportMark.rated3:
        return 3;
      case UITaskReportMark.rated4:
        return 4;
      case UITaskReportMark.rated5:
        return 5;
      default:
        return null;
    }
  }
}

class UITaskReport {
	final String planName;
	final UITask task;
	final UIChild child;
	final int taskTimer;
	final int breakCount;
	final int breakTimer;
	final TimeDate taskDate;

	UITaskReportMark ratingMark;
	String ratingComment;

  UITaskReport({
		this.planName,
		this.task,
		this.child,
		this.taskTimer,
		this.breakCount,
		this.breakTimer,
		this.taskDate,
		this.ratingMark = UITaskReportMark.notRated,
		this.ratingComment
	});

	List<Object> get props => [planName, task, child, taskTimer, breakCount, breakTimer, taskDate];

}
