import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fokus/logic/child/child_rewards_cubit.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/app_paths.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/buttons/rounded_button.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/model/db/user/user_role.dart';

class RewardDialog extends StatefulWidget {
	final UIReward reward;
	final Function claimFeedback;

	RewardDialog({@required this.reward, this.claimFeedback});

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
		var userRole = context.watch<AuthenticationBloc>().state.user.role;
		return Dialog(
	    insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
	    child: SingleChildScrollView(
	      child: Padding(
	        padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
	        child: Column(
	          mainAxisSize: MainAxisSize.min,
	          children: [
	            if(userRole == UserRole.child)
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
	                  child: SvgPicture.asset(AssetType.rewards.getPath(widget.reward.icon), height: MediaQuery.of(context).size.width*0.3)
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
	                  AppLocales.of(context).translate('rewards.claimCostLabel') + ': ',
	                  style: TextStyle(color: AppColors.mediumTextColor)
	                ),
	                AttributeChip.withCurrency(
	                  currencyType: widget.reward.cost.type,
	                  content: widget.reward.cost.quantity.toString(),
	                  tooltip: widget.reward.cost.title
	                )
	              ]
	            ),
	            Padding(
	              padding: EdgeInsets.symmetric(vertical: 16.0),
	              child: Row(
	                mainAxisAlignment: MainAxisAlignment.center,
	                children: <Widget>[
	                  RoundedButton(button: UIButton('actions.close', () => Navigator.of(context).pop(), Colors.blueGrey, Icons.close)),
	                  if(userRole == UserRole.child)
	                    BlocBuilder<ChildRewardsCubit, StatefulState>(
	                      builder: (context, state) => RoundedButton(
	                        button: UIButton(
	                          '$_pageKey.claimButton',
	                          state.submissionInProgress ? null : widget.claimFeedback,
	                          AppColors.childButtonColor,
	                          Icons.add_shopping_cart
	                        )
	                      )
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
