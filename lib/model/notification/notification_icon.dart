import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/app_paths.dart';

class NotificationIcon {
	final AssetType type;
	final int index;

  const NotificationIcon(this.type, this.index);

  String get getPath => type.getPath(index, AssetPathType.drawable);
}
