import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fokus/data/model/date/time_date.dart';

class TaskWidget extends StatelessWidget {
  final String name;
  final TimeDate timeDate;

  TaskWidget(this.name, this.timeDate);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
					padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  this.name,
                  style: Theme.of(context).textTheme.headline2, maxLines: 3, overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 5), child: Row(
						children: <Widget>[
							Flexible(
								child: Text(this.timeDate.minute.toString() + " minut", style: Theme.of(context).textTheme.bodyText1),
							),

						],
					),)
        ],
      ),
    ));
  }
}
