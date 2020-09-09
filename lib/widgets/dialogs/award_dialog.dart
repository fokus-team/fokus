import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/model/ui/gamification/ui_award.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/buttons/rounded_button.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';

class AwardDialog extends StatefulWidget {
	final UIAward award;

	AwardDialog({@required this.award});

	@override
	_AwardDialogState createState() => new _AwardDialogState();
}

class _AwardDialogState extends State<AwardDialog> with SingleTickerProviderStateMixin {
  static const String _pageKey = 'page.childSection.awards.content';
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
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [				
					Padding(
						padding: EdgeInsets.all(20.0).copyWith(bottom: 0), 
						child: Text(
							AppLocales.of(context).translate('$_pageKey.claimAwardTitle'),
							style: Theme.of(context).textTheme.headline6
						)
					),
					Stack(
						alignment: Alignment.center,
						children: [
							RotationTransition(
								turns: Tween(begin: 0.0, end: 1.0).animate(_rotationController),
								child: SvgPicture.asset('assets/image/sunrays.svg', height: 220)
							),
							Padding(
								padding: EdgeInsets.only(top: 10.0),
								child: SvgPicture.asset(awardIconSvgPath(widget.award.icon), height: 120)
							)
						]
					),
					Text(
						widget.award.name,
						style: Theme.of(context).textTheme.headline1,
						textAlign: TextAlign.center
					),
					SizedBox(height: 6.0),
					Wrap(
						alignment: WrapAlignment.center,
						crossAxisAlignment: WrapCrossAlignment.center,
						spacing: 2.0,
						children: [
							Text(
								AppLocales.of(context).translate('$_pageKey.claimCostLabel') + ': ',
								style: TextStyle(color: AppColors.mediumTextColor)
							),
							AttributeChip.withCurrency(
								currencyType: widget.award.points.type,
								content: widget.award.points.quantity.toString()
							)
						]
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
									dense: true,
								),
								RoundedButton(
									icon: Icons.add,
									text: AppLocales.of(context).translate('$_pageKey.claimButton'),
									color: AppColors.childButtonColor,
									onPressed: () => { /* TODO Claim award */ },
									dense: true,
								)
							]
						)
					)
				]
			)
		);
  }

}
