import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/buttons/rounded_button.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';

class RewardDialog extends StatefulWidget {
	final UIReward reward;
	final bool showHeader;

	RewardDialog({@required this.reward, this.showHeader});

	@override
	_RewardDialogState createState() => new _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> with SingleTickerProviderStateMixin {
  static const String _pageKey = 'page.childSection.rewards.content';
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
					padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [		
							if(widget.showHeader)		
								Padding(
									padding: EdgeInsets.all(20.0).copyWith(bottom: 0), 
									child: Text(
										AppLocales.of(context).translate('$_pageKey.claimRewardTitle'),
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
										child: SvgPicture.asset(rewardIconSvgPath(widget.reward.icon), height: MediaQuery.of(context).size.width*0.3)
									)
								]
							),
							Text(
								widget.reward.name,
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
										currencyType: widget.reward.cost.type,
										content: widget.reward.cost.quantity.toString()
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
											dense: true
										),
										if(widget.showHeader)
											RoundedButton(
												icon: Icons.add,
												text: AppLocales.of(context).translate('$_pageKey.claimButton'),
												color: AppColors.childButtonColor,
												onPressed: () => { /* TODO Claim reward */ },
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
