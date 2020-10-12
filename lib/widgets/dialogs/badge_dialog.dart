import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/app_paths.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/widgets/buttons/rounded_button.dart';
import 'package:intl/intl.dart';

class BadgeDialog extends StatefulWidget {
	final UIBadge badge;
	final bool showHeader;

	BadgeDialog({@required this.badge, this.showHeader});

	@override
	_BadgeDialogState createState() => new _BadgeDialogState();
}

class _BadgeDialogState extends State<BadgeDialog> with SingleTickerProviderStateMixin {
  static const String _pageKey = 'page.childSection.achievements.content';
	AnimationController _rotationController;

	@override
	void initState() {
		_rotationController = AnimationController(duration: const Duration(seconds: 30), vsync: this);
		_rotationController.repeat();
		super.initState();
	}

	@override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
		return Dialog(
			insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
			child: SingleChildScrollView(
				child: Padding(
					padding: EdgeInsets.symmetric(horizontal: 30.0),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							if(widget.showHeader)	
								Padding(
									padding: EdgeInsets.all(20.0).copyWith(bottom: 0), 
									child: Text(
										AppLocales.of(context).translate('$_pageKey.earnedBadgeTitle'),
										style: Theme.of(context).textTheme.headline6
									)
								),
							Stack(
								alignment: Alignment.center,
								children: [
									RotationTransition(
										turns: Tween(begin: 0.0, end: 1.0).animate(_rotationController),
										child: SvgPicture.asset('assets/image/sunrays.svg', height: MediaQuery.of(context).size.width*0.5)
									),
									Padding(
										padding: EdgeInsets.only(top: 10.0),
										child: SvgPicture.asset(AssetType.badges.getPath(widget.badge.icon), height: MediaQuery.of(context).size.width*0.3)
									)
								]
							),
							Text(
								widget.badge.name,
								style: Theme.of(context).textTheme.headline1,
								textAlign: TextAlign.center
							),
							SizedBox(height: 6.0),
							if(widget.badge is UIChildBadge && (widget.badge as UIChildBadge).date != null)
								Text(
									AppLocales.of(context).translate('$_pageKey.earnedBadgeDate') + ': '
										+ DateFormat.yMd(AppLocales.instance.locale.toString()).format((widget.badge as UIChildBadge).date),
									style: Theme.of(context).textTheme.caption,
									textAlign: TextAlign.center
								),
							if(widget.badge.description != null)
								Padding(
									padding: EdgeInsets.symmetric(vertical: 10.0),
									child: Text(
										widget.badge.description,
										style: Theme.of(context).textTheme.bodyText2,
										textAlign: TextAlign.center
									)
								),
							Padding(
								padding: EdgeInsets.symmetric(vertical: 16.0),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: <Widget>[
										RoundedButton(
											icon: Icons.close,
											text: AppLocales.of(context).translate('actions.close'),
											color: Colors.grey,
											onPressed: () => Navigator.of(context).pop(),
											dense: true
										)
									]
								)
							)
						]
					)
				)
			)
		);
  }

}
