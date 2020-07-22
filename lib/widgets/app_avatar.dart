import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/utils/app_paths.dart';

class AppAvatar extends StatelessWidget {
	final int avatar;
	final double size;
	final Color color;
	//final UserType type; // in case of caregivers having avatars

	AppAvatar(
		this.avatar,
		{
			//this.type = UserType.child,
			this.size = 64,
			this.color = Colors.transparent
		}
	);

	@override
  Widget build(BuildContext context) {
		return ClipOval(
			child: Container(
				width: size,
				height: size,
				color: color,
				child: Transform.translate(
					offset: const Offset(0.0, 8.0),
					child: SvgPicture.asset(childAvatarSvgPath(avatar), fit: BoxFit.contain)
				)
			)
		);
	}
}
