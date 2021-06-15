import 'package:fokus/model/ui/child_card_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChildDashboardParams {
	final ChildCardModel childCard;
	final int? tab;
	final ObjectId? id;

  ChildDashboardParams({required this.childCard, this.tab, this.id});
}
