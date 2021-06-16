import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/ui/app_paths.dart';
import '../../utils/ui/icon_sets.dart';

class AppAvatar extends StatelessWidget {
	final int? avatar;
	final double? size;
	final Color? color;
	final bool? checked;
	final bool disabled;
	final bool blankAvatar;
	final String? caregiverPhotoURL;

	static final Color greyOut = Colors.grey[100]!;

	AppAvatar(
		this.avatar,
		{
			this.size = 64,
			this.color,
			this.checked,
			this.disabled = false,
			this.blankAvatar = false,
			this.caregiverPhotoURL
		}
	);

	AppAvatar.blank({double? size}) : this(0, size: size, color: greyOut, blankAvatar: true);

	@override
  Widget build(BuildContext context) {
		if(caregiverPhotoURL != null) {
			return Container(
				width: size,
				height: size,
				child: CircleAvatar(
					radius: 64.0,
					backgroundImage: NetworkImage(caregiverPhotoURL!),
					backgroundColor: Colors.transparent
				)
			);
		}
		return Badge(
			badgeContent: Icon(Icons.check, color: Colors.white, size: 16.0),
			badgeColor: Colors.green,
			animationType: BadgeAnimationType.scale,
			showBadge: checked != null ? checked! : false,
			child: ClipOval(
				child: Container(
					width: size,
					height: size,
					foregroundDecoration: disabled ? BoxDecoration(
						color: greyOut,
						backgroundBlendMode: BlendMode.saturation
					) : null,
					color: (color != null) ? color : childAvatars[avatar]?.color,
					child: Transform.translate(
						offset: const Offset(0.0, 8.0),
						child: blankAvatar ? 
						SvgPicture.asset('assets/image/avatar/default.svg', fit: BoxFit.fitHeight)
						: SvgPicture.asset(AssetType.avatars.getPath(avatar), fit: BoxFit.fitHeight)
					)
				)
			)
		);
	}
}
