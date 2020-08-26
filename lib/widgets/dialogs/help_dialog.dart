import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/general/app_loader.dart';

class HelpDialog extends StatelessWidget {
  final String helpPage;

  HelpDialog({
    @required this.helpPage
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context)
    );
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 10.0),
                child: Icon(Icons.help_outline)
              ),
              Text(AppLocales.of(context).translate('help.' + helpPage), style: Theme.of(context).textTheme.headline2)
            ],
          ),
          SizedBox(height: 6.0),
          Divider(),
          FutureBuilder(
            future: rootBundle.loadString(helpPagePath(context, helpPage)),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Markdown(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    p: Theme.of(context).textTheme.bodyText2
                  ),
                  data: snapshot.data
                );
              }
              return Center(child: Padding(padding: EdgeInsets.all(10.0), child: AppLoader()));
            }
          ),
          SizedBox(height: 4.0),
          Align(
            alignment: Alignment.bottomRight,
            child: FlatButton(
              onPressed: () => { Navigator.of(context).pop() },
              child: Text(AppLocales.of(context).translate(ButtonType.close.key))
            )
          )
        ]
      )
    );
  }

}
