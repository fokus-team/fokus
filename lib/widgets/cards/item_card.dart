import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/general/app_avatar.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';

class ItemCardActionButton {
	final IconData icon;
	final Color color;
	final Function onTapped;
	final bool disabled;
	final double size;

	ItemCardActionButton({
		this.icon,
		this.color,
		this.onTapped,
		this.size = 40.0,
		this.disabled = false
	});
}

class ItemCard extends StatelessWidget {
	// Element's content
	final String title;
	final String subtitle;
	final Widget icon;
	final AssetType graphicType;
	final int graphic;
	final double graphicHeight;
	final bool graphicShowCheckmark;
	final double progressPercentage;
	final List<Widget> chips;
	final List<UIButton> menuItems;
	final ItemCardActionButton actionButton;
	final Function onTapped;
	final bool isActive;
	final int textMaxLines;
	final Color activeProgressBarColor;

	// Element's visual params
	final int titleMaxLines = 3;
	static const double defaultImageHeight = 76.0;
	final double progressIndicatorHeight = 10.0;
	final Color disabledButtonColor = Colors.grey[200];
  final Color inactiveProgressBar = Colors.grey[300];

	ItemCard({
		@required this.title, 
		this.subtitle,
		this.icon,
		this.graphicType,
		this.graphic,
		this.graphicHeight = defaultImageHeight,
		this.graphicShowCheckmark,
		this.progressPercentage,
		this.chips,
		this.menuItems,
		this.actionButton,
		this.onTapped,
		this.isActive = true,
		this.textMaxLines = 3,
		this.activeProgressBarColor = AppColors.childBackgroundColor
	}) : assert(graphic != null ? graphicType != null : true);
	
	Widget headerImage() {
		switch(graphicType) {
			case AssetType.avatars:
				return AppAvatar(graphic, size: graphicHeight, color: childAvatars[graphic].color, checked: graphicShowCheckmark);
			break;
			case AssetType.rewards:
				return SvgPicture.asset(graphicType.getPath(graphic), height: graphicHeight);
			break;
			case AssetType.badges:
				return Badge(
					showBadge: graphicShowCheckmark ?? false,
					badgeColor: Colors.green,
					badgeContent: Icon(Icons.check, color: Colors.white, size: 16.0),
					child: SvgPicture.asset(graphicType.getPath(graphic), height: graphicHeight)
				);
			break;
			default:
				return Image.asset('assets/image/sunflower_logo.png', height: graphicHeight);
			break;
		}
	}

	// Card's shape and interaction
	@override
	Widget build(BuildContext context) {
		return IntrinsicHeight(
			child: Card(
				elevation: isActive ? 1.2 : 0.6,
				color: isActive ? Colors.white : disabledButtonColor,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)),
				margin: EdgeInsets.symmetric(
					vertical: AppBoxProperties.cardListPadding,
					horizontal: AppBoxProperties.screenEdgePadding
				),
				child: (onTapped != null) ? InkWell(
					onTap: onTapped, 
					child:  buildStructure(context),
					borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)
				) : buildStructure(context)
			)
		);
	}

	// Layout: MainSection | ActionSection
	Widget buildbaseLayout(BuildContext context) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				buildMainSection(context),
				if((menuItems != null && menuItems.isNotEmpty) || actionButton != null)
					buildActionSection()
			]
		);
	}

	// Structure change depending on big action button (progress bar goes under ActionSection)
	Widget buildStructure(BuildContext context) {
		if(progressPercentage != null && actionButton == null) 
			return Column(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					buildbaseLayout(context),
					buildProgressBar()
				]
			);
		return buildbaseLayout(context);
	}

	// Inner structure of MainSection (content + sometimes progress bar)
	Widget buildMainSection(BuildContext context) {
		return Flexible(
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: (progressPercentage != null) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
				children: <Widget>[
					buildContentSection(context),
					if(progressPercentage != null && actionButton != null)
						buildProgressBar()
				]
			)
		);
	}

	// Image, title, subtitle and chips
	Widget buildContentSection(BuildContext context) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.start,
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				if(graphic != null || icon != null)
					Padding(
						padding: EdgeInsets.all(6.0),
						child: icon != null ? icon : headerImage()
					),
				Expanded(
					flex: 1, 
					child: Padding(
						padding: (graphic != null) ? EdgeInsets.all(6.0) : EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>[
								Text(
									title, 
									style: Theme.of(context).textTheme.headline3,
									overflow: TextOverflow.ellipsis,
									maxLines: textMaxLines
								),
								if(subtitle != null)
									Text(
										subtitle, 
										style: Theme.of(context).textTheme.subtitle2,
										overflow: TextOverflow.ellipsis,
										maxLines: textMaxLines,
										softWrap: false,
									),
								if(chips != null && chips.isNotEmpty)
									Padding(
										padding: EdgeInsets.only(top: 8.0),
										child: Wrap(
											spacing: 2,
											runSpacing: 4,
											children: chips
										)
									)
							],
						)
					)
				)
			]
		);
	}

	// Bottom progress bar
	Widget buildProgressBar() {
		return Container(
			height: progressIndicatorHeight,
			decoration: BoxDecoration(
				borderRadius: actionButton != null ?
					BorderRadius.only(bottomLeft: Radius.circular(AppBoxProperties.roundedCornersRadius))
					: BorderRadius.vertical(bottom: Radius.circular(AppBoxProperties.roundedCornersRadius))
			),
			clipBehavior: Clip.hardEdge,
			child: LinearProgressIndicator(
				value: progressPercentage,
				backgroundColor: inactiveProgressBar,
				valueColor: AlwaysStoppedAnimation<Color>(activeProgressBarColor)
			)
		);
	}

	// Menu options or big action button
	Widget buildActionSection() {
		if(menuItems != null && menuItems.isNotEmpty) {
			return PopupMenuList(items: menuItems);
		}
		if(actionButton != null) {
			if(actionButton.disabled) {
				return FlatButton(
					onPressed: null,
					disabledColor: inactiveProgressBar,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(AppBoxProperties.roundedCornersRadius))),
					child: Center(
						child: Icon(actionButton.icon, color: Colors.white, size: actionButton.size),
					)
				);
			} else {
				return FlatButton(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(AppBoxProperties.roundedCornersRadius))),
					onPressed: actionButton.disabled ? null : actionButton.onTapped,
					color: actionButton.color,
					disabledColor: disabledButtonColor,
					child: Center(
						child: Icon(actionButton.icon, color: Colors.white, size: actionButton.size),
					)
				);
			}
		}
		return SizedBox(width: 0, height: 0);
	}

}
