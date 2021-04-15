import 'package:flutter/material.dart';

enum AssetType { avatars, rewards, badges, currencies }

enum AvatarAssetLabel { boy, girl }
enum RewardAssetLabel { gift, relax, activity, food }
enum BadgeAssetLabel { praise, medal, trophy }

class GraphicAsset<GraphicLabel> {
	final String filename;
	final GraphicLabel label;
	final Color? color;
	
	GraphicAsset(this.filename, this.label, [this.color]);
}

Map<AssetType, Map<int, GraphicAsset>> graphicAssets = {
	AssetType.avatars: childAvatars,
	AssetType.rewards: rewardIcons,
	AssetType.badges: badgeIcons
};

Map<int, GraphicAsset<AvatarAssetLabel>> childAvatars = {
	0: GraphicAsset('boy-0', AvatarAssetLabel.boy, Colors.indigo[400]),
	1: GraphicAsset('boy-1', AvatarAssetLabel.boy, Colors.pink[400]),
	2: GraphicAsset('boy-2', AvatarAssetLabel.boy, Colors.deepPurple[400]),
	3: GraphicAsset('boy-3', AvatarAssetLabel.boy, Colors.purple[400]),
	4: GraphicAsset('boy-4', AvatarAssetLabel.boy, Colors.indigo[400]),
	5: GraphicAsset('boy-5', AvatarAssetLabel.boy, Colors.blue[400]),
	6: GraphicAsset('boy-6', AvatarAssetLabel.boy, Colors.deepPurple[400]),
	7: GraphicAsset('boy-7', AvatarAssetLabel.boy, Colors.blue[400]),
	8: GraphicAsset('boy-8', AvatarAssetLabel.boy, Colors.purple[400]),
	9: GraphicAsset('boy-9', AvatarAssetLabel.boy, Colors.pink[400]),
	10: GraphicAsset('boy-10', AvatarAssetLabel.boy, Colors.indigo[400]),
	11: GraphicAsset('boy-11', AvatarAssetLabel.boy, Colors.deepPurple[400]),
	12: GraphicAsset('boy-12', AvatarAssetLabel.boy, Colors.pink[400]),
	13: GraphicAsset('boy-13', AvatarAssetLabel.boy, Colors.indigo[400]),
	14: GraphicAsset('boy-14', AvatarAssetLabel.boy, Colors.deepPurple[400]),
	15: GraphicAsset('boy-15', AvatarAssetLabel.boy, Colors.purple[400]),
	16: GraphicAsset('boy-16', AvatarAssetLabel.boy, Colors.indigo[400]),
	17: GraphicAsset('boy-17', AvatarAssetLabel.boy, Colors.blue[400]),
	18: GraphicAsset('boy-18', AvatarAssetLabel.boy, Colors.deepPurple[400]),
	19: GraphicAsset('boy-19', AvatarAssetLabel.boy, Colors.blue[400]),
	20: GraphicAsset('girl-0', AvatarAssetLabel.girl, Colors.purple[400]),
	21: GraphicAsset('girl-1', AvatarAssetLabel.girl, Colors.pink[400]),
	22: GraphicAsset('girl-2', AvatarAssetLabel.girl, Colors.deepPurple[400]),
	23: GraphicAsset('girl-3', AvatarAssetLabel.girl, Colors.purple[400]),
	24: GraphicAsset('girl-4', AvatarAssetLabel.girl, Colors.indigo[400]),
	25: GraphicAsset('girl-5', AvatarAssetLabel.girl, Colors.blue[400]),
	26: GraphicAsset('girl-6', AvatarAssetLabel.girl, Colors.deepPurple[400]),
	27: GraphicAsset('girl-7', AvatarAssetLabel.girl, Colors.blue[400]),
	28: GraphicAsset('girl-8', AvatarAssetLabel.girl, Colors.purple[400]),
	29: GraphicAsset('girl-9', AvatarAssetLabel.girl, Colors.pink[400]),
	30: GraphicAsset('girl-10', AvatarAssetLabel.girl, Colors.indigo[400]),
	31: GraphicAsset('girl-11', AvatarAssetLabel.girl, Colors.pink[400]),
	32: GraphicAsset('girl-12', AvatarAssetLabel.girl, Colors.deepPurple[400]),
	33: GraphicAsset('girl-13', AvatarAssetLabel.girl, Colors.purple[400]),
	34: GraphicAsset('girl-14', AvatarAssetLabel.girl, Colors.blue[400]),
	35: GraphicAsset('girl-15', AvatarAssetLabel.girl, Colors.indigo[400]),
	36: GraphicAsset('girl-16', AvatarAssetLabel.girl, Colors.deepPurple[400]),
	37: GraphicAsset('girl-17', AvatarAssetLabel.girl, Colors.blue[400]),
	38: GraphicAsset('girl-18', AvatarAssetLabel.girl, Colors.purple[400]),
	39: GraphicAsset('girl-19', AvatarAssetLabel.girl, Colors.pink[400])
};

Map<int, GraphicAsset<RewardAssetLabel>> rewardIcons = {
	0: GraphicAsset('gift', RewardAssetLabel.gift),
	1: GraphicAsset('backpack', RewardAssetLabel.activity),
	2: GraphicAsset('basketball', RewardAssetLabel.activity),
	3: GraphicAsset('board-games', RewardAssetLabel.activity),
	4: GraphicAsset('bowling', RewardAssetLabel.activity),
	5: GraphicAsset('cooking', RewardAssetLabel.activity),
	6: GraphicAsset('disco', RewardAssetLabel.relax),
	7: GraphicAsset('food', RewardAssetLabel.food),
	8: GraphicAsset('ice-cream', RewardAssetLabel.food),
	9: GraphicAsset('joystick', RewardAssetLabel.relax),
	10: GraphicAsset('movie', RewardAssetLabel.relax),
	11: GraphicAsset('park', RewardAssetLabel.relax),
	12: GraphicAsset('pizza', RewardAssetLabel.food),
	13: GraphicAsset('shopping', RewardAssetLabel.activity),
	14: GraphicAsset('sofa', RewardAssetLabel.relax),
	15: GraphicAsset('tea', RewardAssetLabel.food),
	16: GraphicAsset('ticket', RewardAssetLabel.relax),
	17: GraphicAsset('time-planning', RewardAssetLabel.relax),
	18: GraphicAsset('walking', RewardAssetLabel.activity),
	19: GraphicAsset('woods', RewardAssetLabel.activity)
};

Map<int, GraphicAsset<BadgeAssetLabel>> badgeIcons = {
	0: GraphicAsset('crown', BadgeAssetLabel.praise),
	1: GraphicAsset('diploma', BadgeAssetLabel.praise),
	2: GraphicAsset('thumbs-up', BadgeAssetLabel.praise),
	3: GraphicAsset('trophy-0', BadgeAssetLabel.trophy),
	4: GraphicAsset('trophy-1', BadgeAssetLabel.trophy),
	5: GraphicAsset('trophy-2', BadgeAssetLabel.trophy),
	6: GraphicAsset('trophy-3', BadgeAssetLabel.trophy),
	7: GraphicAsset('trophy-4', BadgeAssetLabel.trophy),
	8: GraphicAsset('trophy-5', BadgeAssetLabel.trophy),
	9: GraphicAsset('trophy-6', BadgeAssetLabel.trophy),
	10: GraphicAsset('trophy-7', BadgeAssetLabel.trophy),
	11: GraphicAsset('trophy-8', BadgeAssetLabel.trophy),
	12: GraphicAsset('medal-0', BadgeAssetLabel.medal),
	13: GraphicAsset('medal-1', BadgeAssetLabel.medal),
	14: GraphicAsset('medal-2', BadgeAssetLabel.medal),
	15: GraphicAsset('medal-3', BadgeAssetLabel.medal),
	16: GraphicAsset('medal-4', BadgeAssetLabel.medal),
	17: GraphicAsset('medal-5', BadgeAssetLabel.medal),
	18: GraphicAsset('medal-6', BadgeAssetLabel.medal),
	19: GraphicAsset('medal-7', BadgeAssetLabel.medal)
};
