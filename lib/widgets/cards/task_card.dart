import 'package:flutter/material.dart';
import '../../model/ui/form/task_form_model.dart';
import '../../services/app_locales.dart';
import '../chips/attribute_chip.dart';

class TaskCard extends StatelessWidget {
	final TaskFormModel task;
	final int? index;
	final void Function(TaskFormModel)? onTap;

	TaskCard({
		required this.task,
		required this.index,
		this.onTap
	});

  @override
  Widget build(BuildContext context) {
		var haveSetPoints = task.pointsValue != null && task.pointsValue != 0;
		var haveSetTimer = task.timer != null && task.timer != 0;
		
		return Card(
			child: InkWell(
				onTap: () => onTap != null ? onTap!(task) : () => {},
				splashColor: onTap != null ? Colors.blueGrey[50] : Colors.transparent,
				highlightColor: onTap != null ? Colors.blueGrey[50] : Colors.transparent,
				child: Padding(
					padding: EdgeInsets.all(6.0),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.start,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: <Widget>[
							AttributeChip.withIcon(
								content: task.optional! ? null : '#${(index!+1).toString()}',
								icon: task.optional! ? Icons.label_important : null,
								color: Colors.blueGrey[600]
							),
							Expanded(
								child: Padding(
									padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
									child: Column(
										mainAxisSize: MainAxisSize.min,
										mainAxisAlignment: MainAxisAlignment.start,
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Padding(
												padding: EdgeInsets.only(left: 0, bottom: (!haveSetTimer && !haveSetPoints) ? 0.0 : 8.0),
													child: Hero(
													tag: task.key,
													child: Text(
														task.title!,
														style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 17.0),
														maxLines: 3,
														overflow: TextOverflow.ellipsis
													)
												)
											),
											Wrap(
												runSpacing: 2.0,
												spacing: 4.0,
												children: [
													if(haveSetPoints)
														AttributeChip.withCurrency(
															content: task.pointsValue.toString(),
															currencyType: task.pointCurrency!.type!,
															tooltip: task.pointCurrency!.name
														),
													if(haveSetTimer)
														AttributeChip.withIcon(
															content: AppLocales.of(context).translate('page.caregiverSection.taskForm.fields.taskTimer.format', {
																'HOURS_NUM': (task.timer! ~/ 60).toString(),
																'MINUTES_NUM': (task.timer! % 60).toString()
															}),
															icon: Icons.timer, 
															color: Colors.orange
														)
												]
											)
										]
									)
								)
							),
							if(onTap != null)
								Padding(
									padding: EdgeInsets.all(2.0),
									child: Icon(Icons.call_made, color: Colors.grey)
								)
						]
					)
				)
			)
		);
  }

}
