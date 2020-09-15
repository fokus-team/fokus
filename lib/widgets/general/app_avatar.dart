import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/icon_sets.dart';

class AppAvatar extends StatelessWidget {
	final int avatar;
	final double size;
	final Color color;
	final bool checked;
	final bool disabled;
	final bool blankAvatar;
	//final UserType type; // in case of caregivers having avatars

	static final Color greyOut = Colors.grey[100];

	AppAvatar(
		this.avatar,
		{
			//this.type = UserType.child,
			this.size = 64,
			this.color,
			this.checked,
			this.disabled = false,
			this.blankAvatar = false
		}
	);

	AppAvatar.blank({double size}) : this(0, size: size, color: greyOut, blankAvatar: true);

	@override
  Widget build(BuildContext context) {
		return Badge(
			badgeContent: Icon(Icons.check, color: Colors.white, size: 16.0),
			badgeColor: Colors.green,
			animationType: BadgeAnimationType.scale,
			showBadge: checked != null ? checked : false,
			child: ClipOval(
				child: Container(
					width: size,
					height: size,
					foregroundDecoration: disabled ? BoxDecoration(
						color: greyOut,
						backgroundBlendMode: BlendMode.saturation
					) : null,
					color: (color != null) ? color : childAvatars[this.avatar].color,
					child: Transform.translate(
						offset: const Offset(0.0, 8.0),
						child: blankAvatar ? 
						SvgPicture.asset('assets/image/avatar/default.svg', fit: BoxFit.fitHeight)
						: SvgPicture.asset(AssetType.childAvatars.getPath(avatar), fit: BoxFit.fitHeight)
					)
				)
			)
		);
	}
}
