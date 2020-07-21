import 'package:flutter/material.dart';

enum GraphicAssetType { childAvatars, awardsIcons, badgeIcons }

enum ChildAvatarAssetLabel { boy, girl }
enum AwardsIconsAssetLabel { gift, relax, activity, food }
enum BadgeIconsAssetLabel { praise, medal, trophy }

class GraphicAsset<GraphicLabel> {
	final String filename;
	final GraphicLabel label;
	final Color color;
	
	GraphicAsset(this.filename, this.label, [this.color]);
}

Map<GraphicAssetType, Map<int, GraphicAsset>> graphicAssets = {
	GraphicAssetType.childAvatars: childAvatars,
	GraphicAssetType.awardsIcons: awardIcons,
	GraphicAssetType.badgeIcons: badgeIcons
};

Map<int, GraphicAsset<ChildAvatarAssetLabel>> childAvatars = {
	0: GraphicAsset('boy-0', ChildAvatarAssetLabel.boy, Colors.indigo[400]),
	1: GraphicAsset('boy-1', ChildAvatarAssetLabel.boy, Colors.pink[400]),
	2: GraphicAsset('boy-2', ChildAvatarAssetLabel.boy, Colors.deepPurple[400]),
	3: GraphicAsset('boy-3', ChildAvatarAssetLabel.boy, Colors.purple[400]),
	4: GraphicAsset('boy-4', ChildAvatarAssetLabel.boy, Colors.indigo[400]),
	5: GraphicAsset('boy-5', ChildAvatarAssetLabel.boy, Colors.blue[400]),
	6: GraphicAsset('boy-6', ChildAvatarAssetLabel.boy, Colors.deepPurple[400]),
	7: GraphicAsset('boy-7', ChildAvatarAssetLabel.boy, Colors.blue[400]),
	8: GraphicAsset('boy-8', ChildAvatarAssetLabel.boy, Colors.purple[400]),
	9: GraphicAsset('boy-9', ChildAvatarAssetLabel.boy, Colors.pink[400]),
	10: GraphicAsset('boy-10', ChildAvatarAssetLabel.boy, Colors.indigo[400]),
	11: GraphicAsset('boy-11', ChildAvatarAssetLabel.boy, Colors.deepPurple[400]),
	12: GraphicAsset('boy-12', ChildAvatarAssetLabel.boy, Colors.pink[400]),
	13: GraphicAsset('boy-13', ChildAvatarAssetLabel.boy, Colors.indigo[400]),
	14: GraphicAsset('boy-14', ChildAvatarAssetLabel.boy, Colors.deepPurple[400]),
	15: GraphicAsset('boy-15', ChildAvatarAssetLabel.boy, Colors.purple[400]),
	16: GraphicAsset('boy-16', ChildAvatarAssetLabel.boy, Colors.indigo[400]),
	17: GraphicAsset('boy-17', ChildAvatarAssetLabel.boy, Colors.blue[400]),
	18: GraphicAsset('boy-18', ChildAvatarAssetLabel.boy, Colors.deepPurple[400]),
	19: GraphicAsset('boy-19', ChildAvatarAssetLabel.boy, Colors.blue[400]),
	20: GraphicAsset('girl-0', ChildAvatarAssetLabel.girl, Colors.purple[400]),
	21: GraphicAsset('girl-1', ChildAvatarAssetLabel.girl, Colors.pink[400]),
	22: GraphicAsset('girl-2', ChildAvatarAssetLabel.girl, Colors.deepPurple[400]),
	23: GraphicAsset('girl-3', ChildAvatarAssetLabel.girl, Colors.purple[400]),
	24: GraphicAsset('girl-4', ChildAvatarAssetLabel.girl, Colors.indigo[400]),
	25: GraphicAsset('girl-5', ChildAvatarAssetLabel.girl, Colors.blue[400]),
	26: GraphicAsset('girl-6', ChildAvatarAssetLabel.girl, Colors.deepPurple[400]),
	27: GraphicAsset('girl-7', ChildAvatarAssetLabel.girl, Colors.blue[400]),
	28: GraphicAsset('girl-8', ChildAvatarAssetLabel.girl, Colors.purple[400]),
	29: GraphicAsset('girl-9', ChildAvatarAssetLabel.girl, Colors.pink[400]),
	30: GraphicAsset('girl-10', ChildAvatarAssetLabel.girl, Colors.indigo[400]),
	31: GraphicAsset('girl-11', ChildAvatarAssetLabel.girl, Colors.pink[400]),
	32: GraphicAsset('girl-12', ChildAvatarAssetLabel.girl, Colors.deepPurple[400]),
	33: GraphicAsset('girl-13', ChildAvatarAssetLabel.girl, Colors.purple[400]),
	34: GraphicAsset('girl-14', ChildAvatarAssetLabel.girl, Colors.blue[400]),
	35: GraphicAsset('girl-15', ChildAvatarAssetLabel.girl, Colors.indigo[400]),
	36: GraphicAsset('girl-16', ChildAvatarAssetLabel.girl, Colors.deepPurple[400]),
	37: GraphicAsset('girl-17', ChildAvatarAssetLabel.girl, Colors.blue[400]),
	38: GraphicAsset('girl-18', ChildAvatarAssetLabel.girl, Colors.purple[400]),
	39: GraphicAsset('girl-19', ChildAvatarAssetLabel.girl, Colors.pink[400])
};

Map<int, GraphicAsset<AwardsIconsAssetLabel>> awardIcons = {
	0: GraphicAsset('gift', AwardsIconsAssetLabel.gift),
	1: GraphicAsset('backpack', AwardsIconsAssetLabel.activity),
	2: GraphicAsset('basketball', AwardsIconsAssetLabel.activity),
	3: GraphicAsset('board-games', AwardsIconsAssetLabel.activity),
	4: GraphicAsset('bowling', AwardsIconsAssetLabel.activity),
	5: GraphicAsset('cooking', AwardsIconsAssetLabel.activity),
	6: GraphicAsset('disco', AwardsIconsAssetLabel.relax),
	7: GraphicAsset('food', AwardsIconsAssetLabel.food),
	8: GraphicAsset('ice-cream', AwardsIconsAssetLabel.food),
	9: GraphicAsset('joystick', AwardsIconsAssetLabel.relax),
	10: GraphicAsset('movie', AwardsIconsAssetLabel.relax),
	11: GraphicAsset('park', AwardsIconsAssetLabel.relax),
	12: GraphicAsset('pizza', AwardsIconsAssetLabel.food),
	13: GraphicAsset('shopping', AwardsIconsAssetLabel.activity),
	14: GraphicAsset('sofa', AwardsIconsAssetLabel.relax),
	15: GraphicAsset('tea', AwardsIconsAssetLabel.food),
	16: GraphicAsset('ticket', AwardsIconsAssetLabel.relax),
	17: GraphicAsset('time-planning', AwardsIconsAssetLabel.relax),
	18: GraphicAsset('walking', AwardsIconsAssetLabel.activity),
	19: GraphicAsset('woods', AwardsIconsAssetLabel.activity)
};

Map<int, GraphicAsset<BadgeIconsAssetLabel>> badgeIcons = {
	0: GraphicAsset('crown', BadgeIconsAssetLabel.praise),
	1: GraphicAsset('diploma', BadgeIconsAssetLabel.praise),
	2: GraphicAsset('thumbs-up', BadgeIconsAssetLabel.praise),
	3: GraphicAsset('trophy-0', BadgeIconsAssetLabel.trophy),
	4: GraphicAsset('trophy-1', BadgeIconsAssetLabel.trophy),
	5: GraphicAsset('trophy-2', BadgeIconsAssetLabel.trophy),
	6: GraphicAsset('trophy-3', BadgeIconsAssetLabel.trophy),
	7: GraphicAsset('trophy-4', BadgeIconsAssetLabel.trophy),
	8: GraphicAsset('trophy-5', BadgeIconsAssetLabel.trophy),
	9: GraphicAsset('trophy-6', BadgeIconsAssetLabel.trophy),
	10: GraphicAsset('trophy-7', BadgeIconsAssetLabel.trophy),
	11: GraphicAsset('trophy-8', BadgeIconsAssetLabel.trophy),
	12: GraphicAsset('medal-0', BadgeIconsAssetLabel.medal),
	13: GraphicAsset('medal-1', BadgeIconsAssetLabel.medal),
	14: GraphicAsset('medal-2', BadgeIconsAssetLabel.medal),
	15: GraphicAsset('medal-3', BadgeIconsAssetLabel.medal),
	16: GraphicAsset('medal-4', BadgeIconsAssetLabel.medal),
	17: GraphicAsset('medal-5', BadgeIconsAssetLabel.medal),
	18: GraphicAsset('medal-6', BadgeIconsAssetLabel.medal),
	19: GraphicAsset('medal-7', BadgeIconsAssetLabel.medal)
};
