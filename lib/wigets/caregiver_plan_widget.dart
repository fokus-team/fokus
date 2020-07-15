import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ParentPlanWidget extends StatelessWidget {
  final String name, recurrence;

  ParentPlanWidget(this.name, this.recurrence);

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
                      style: Theme.of(context).textTheme.headline1,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5),child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      this.recurrence,
                      style: Theme.of(context).textTheme.bodyText2,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              )),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      "Przypisane dzieci:",
                      style: Theme.of(context).textTheme.bodyText2,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  ButtonBar(
										children: <Widget>[Icon(Icons.person), Text("Gosia", style: Theme.of(context).textTheme.headline6,)],
									)
                ],
              )
            ]),
      ),
    );
  }
}
