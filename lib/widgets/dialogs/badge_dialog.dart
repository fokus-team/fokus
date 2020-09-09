import 'package:flutter/material.dart';

class BadgeDialog extends StatefulWidget {
	@override
	_BadgeDialogState createState() => new _BadgeDialogState();
}

class _BadgeDialogState extends State<BadgeDialog> {

  @override
  Widget build(BuildContext context) {
		return Dialog(
			insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
			child: Column(
				children: []
			)
		);
  }

}
