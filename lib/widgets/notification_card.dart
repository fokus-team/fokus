import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/widgets/item_card.dart';


class NotificationCard extends ItemCard {
  NotificationCard({
    title,
    subtitle,
    graphic,
    progressPercentage,
    chips,
    menuItems,
    actionButton,
    onTapped,
    isActive = true
  }) : super(
  title: title,
  subtitle: subtitle,
  graphicType: GraphicAssetType.childAvatars,
  graphic: graphic,
  progressPercentage: progressPercentage,
  chips: chips,
  menuItems: menuItems,
  actionButton: actionButton,
  onTapped: onTapped,
  isActive: isActive
  );

  @override
  double get imageHeight => super.imageHeight * 0.7;
}
