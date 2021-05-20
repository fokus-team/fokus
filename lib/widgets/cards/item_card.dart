import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/utils/ui/app_paths.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:fokus/widgets/general/app_avatar.dart';

class ItemCardActionButton {
	final IconData icon;
	final Color color;
	final Function? onTapped;
	final bool disabled;
	final double size;

	ItemCardActionButton({
		required this.icon,
		required this.color,
		this.onTapped,
		this.size = 40.0,
		this.disabled = false
	});
}

class ItemCard extends StatelessWidget {
	// Element's content
	final String title;
	final String? subtitle;
	final Widget? icon;
	final Icon? rightIcon;
	final AssetType? graphicType;
	final int? graphic;
	final double graphicHeight;
	final bool? graphicShowCheckmark;
	final double? progressPercentage;
	final List<Widget>? chips;
	final List<UIButton>? menuItems;
	final ItemCardActionButton? actionButton;
	final Function? onTapped;
	final bool isActive;
	final int textMaxLines;
	final Color? activeProgressBarColor;

	// Element's visual params
	final int titleMaxLines = 3;
	static const double defaultImageHeight = 76.0;
	final double progressIndicatorHeight = 10.0;
	final Color disabledButtonColor = Colors.grey[100]!;
  final Color inactiveProgressBar = Colors.grey[300]!;

	ItemCard({
		required this.title,
		this.subtitle,
		this.icon,
		this.graphicType,
		this.graphic,
		double? graphicHeight,
		this.graphicShowCheckmark,
		this.progressPercentage,
		this.chips,
		this.menuItems,
		this.actionButton,
		this.onTapped,
		this.isActive = true,
		this.textMaxLines = 3,
		this.rightIcon,
		this.activeProgressBarColor = AppColors.childBackgroundColor
	}) : graphicHeight = graphicHeight ?? defaultImageHeight, assert(graphic != null ? graphicType != null : true);
	
	Widget headerImage() {
		if (graphicType == AssetType.avatars)
			return AppAvatar(graphic, size: graphicHeight, color: childAvatars[graphic]!.color, checked: graphicShowCheckmark);
		else if (graphicType == AssetType.badges)
			return Badge(
				showBadge: graphicShowCheckmark ?? false,
				badgeColor: Colors.green,
				badgeContent: Icon(Icons.check, color: Colors.white, size: 16.0),
				child: SvgPicture.asset(graphicType!.getPath(graphic), height: graphicHeight)
			);
		else if (graphicType == AssetType.rewards || graphicType == AssetType.currencies)
			return SvgPicture.asset(graphicType!.getPath(graphic), height: graphicHeight);
		return Image.asset('assets/image/sunflower_logo.png', height: graphicHeight);
	}

	// Card's shape and interaction
	@override
	Widget build(BuildContext context) {
		return Card(
      elevation: isActive ? 1.2 : 0.6,
      color: isActive ? Colors.white : disabledButtonColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)),
      margin: EdgeInsets.symmetric(
        vertical: AppBoxProperties.cardListPadding,
        horizontal: AppBoxProperties.screenEdgePadding
      ),
      child: (onTapped != null) ? InkWell(
        onTap: () => onTapped!,
        child: buildStructure(context),
        borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)
      ) : buildStructure(context)
		);
	}

	// Layout: MainSection | ActionSection
	Widget buildbaseLayout(BuildContext context) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				buildMainSection(context),
				if((menuItems != null && menuItems!.isNotEmpty) || actionButton != null)
					buildActionSection()
			]
		);
	}

	// Structure change depending on big action button (progress bar goes under ActionSection)
	Widget buildStructure(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildbaseLayout(context),
        if(progressPercentage != null)
          buildProgressBar()
      ]
    );
	}

	// Inner structure of MainSection (content + sometimes progress bar)
	Widget buildMainSection(BuildContext context) {
		return Flexible(
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: (progressPercentage != null) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
				children: <Widget>[
					buildContentSection(context)
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
						padding: EdgeInsets.all(8.0),
						child: icon != null ? icon : headerImage()
					),
				Expanded(
					flex: 1, 
					child: Padding(
						padding: (graphic != null) ? EdgeInsets.all(6.0) : EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							mainAxisSize: MainAxisSize.max,
							children: <Widget>[
								...buildTextSection(context),
								if(chips != null && chips!.isNotEmpty)
									Padding(
										padding: EdgeInsets.only(top: 8.0),
										child: Wrap(
											spacing: 2,
											runSpacing: 4,
											children: chips!
										)
									)
							],
						)
					)
				),
				if (rightIcon != null)
					Padding(
						padding: EdgeInsets.all(6.0),
						child: rightIcon
					)
			]
		);
	}

	List<Widget> buildTextSection(BuildContext context) {
		return [
			Text(
				title,
				style: Theme.of(context).textTheme.headline3,
				overflow: TextOverflow.ellipsis,
				maxLines: textMaxLines
			),
			if(subtitle != null)
				Text(
					subtitle!,
					style: Theme.of(context).textTheme.subtitle2,
					overflow: TextOverflow.ellipsis,
					maxLines: textMaxLines,
					softWrap: false,
				),
		];
	}

	// Bottom progress bar
	Widget buildProgressBar() {
		return Container(
			height: progressIndicatorHeight,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppBoxProperties.roundedCornersRadius))
			),
			clipBehavior: Clip.hardEdge,
			child: LinearProgressIndicator(
				value: progressPercentage,
				backgroundColor: inactiveProgressBar,
				valueColor: AlwaysStoppedAnimation<Color>(activeProgressBarColor!)
			)
		);
	}

	// Menu options or big action button
	Widget buildActionSection() {
		if(menuItems != null && menuItems!.isNotEmpty) {
			return PopupMenuList(items: menuItems!);
		}
		if(actionButton != null) {
      return Container(
        margin: EdgeInsets.all(8.0),
        child: Ink(
          decoration: ShapeDecoration(
            color: actionButton!.disabled ? inactiveProgressBar : actionButton!.color,
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppBoxProperties.roundedCornersRadius))),
            shadows: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                blurRadius: 4.0,
                spreadRadius: 2.0
              )
            ]
          ),
          child: MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(8.0),
            onPressed: actionButton!.disabled ? null : () => actionButton!.onTapped,
            child: Icon(actionButton!.icon, color: Colors.white, size: actionButton!.size),
            minWidth: 0
          )
        )
      );
		}
		return SizedBox(width: 0, height: 0);
	}

}
