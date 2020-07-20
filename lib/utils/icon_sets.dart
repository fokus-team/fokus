import 'package:flutter/material.dart';

enum GraphicAssetType { childAvatars, awardsIcons, badgeIcons }

class GraphicAsset {
	final String filename;
	final String label;
	final Color color;
	
	GraphicAsset(this.filename, this.label, [this.color]);
}

Map<GraphicAssetType, Map<int, GraphicAsset>> graphicAssets = {
	GraphicAssetType.childAvatars: childAvatars,
	GraphicAssetType.awardsIcons: awardIcons,
	GraphicAssetType.badgeIcons: badgeIcons
};

Map<int, GraphicAsset> childAvatars = {
	0: GraphicAsset('boy-0','boy', Colors.indigo[400]),
	1: GraphicAsset('boy-1','boy', Colors.pink[400]),
	2: GraphicAsset('boy-2','boy', Colors.deepPurple[400]),
	3: GraphicAsset('boy-3','boy', Colors.purple[400]),
	4: GraphicAsset('boy-4','boy', Colors.indigo[400]),
	5: GraphicAsset('boy-5','boy', Colors.blue[400]),
	6: GraphicAsset('boy-6','boy', Colors.deepPurple[400]),
	7: GraphicAsset('boy-7','boy', Colors.blue[400]),
	8: GraphicAsset('boy-8','boy', Colors.purple[400]),
	9: GraphicAsset('boy-9','boy', Colors.pink[400]),
	10: GraphicAsset('boy-10','boy', Colors.indigo[400]),
	11: GraphicAsset('boy-11','boy', Colors.deepPurple[400]),
	12: GraphicAsset('boy-12','boy', Colors.pink[400]),
	13: GraphicAsset('boy-13','boy', Colors.indigo[400]),
	14: GraphicAsset('boy-14','boy', Colors.deepPurple[400]),
	15: GraphicAsset('boy-15','boy', Colors.purple[400]),
	16: GraphicAsset('boy-16','boy', Colors.indigo[400]),
	17: GraphicAsset('boy-17','boy', Colors.blue[400]),
	18: GraphicAsset('boy-18','boy', Colors.deepPurple[400]),
	19: GraphicAsset('boy-19','boy', Colors.blue[400]),
	20: GraphicAsset('girl-0','girl', Colors.purple[400]),
	21: GraphicAsset('girl-1','girl', Colors.pink[400]),
	22: GraphicAsset('girl-2','girl', Colors.deepPurple[400]),
	23: GraphicAsset('girl-3','girl', Colors.purple[400]),
	24: GraphicAsset('girl-4','girl', Colors.indigo[400]),
	25: GraphicAsset('girl-5','girl', Colors.blue[400]),
	26: GraphicAsset('girl-6','girl', Colors.deepPurple[400]),
	27: GraphicAsset('girl-7','girl', Colors.blue[400]),
	28: GraphicAsset('girl-8','girl', Colors.purple[400]),
	29: GraphicAsset('girl-9','girl', Colors.pink[400]),
	30: GraphicAsset('girl-10','girl', Colors.indigo[400]),
	31: GraphicAsset('girl-11','girl', Colors.pink[400]),
	32: GraphicAsset('girl-12','girl', Colors.deepPurple[400]),
	33: GraphicAsset('girl-13','girl', Colors.purple[400]),
	34: GraphicAsset('girl-14','girl', Colors.blue[400]),
	35: GraphicAsset('girl-15','girl', Colors.indigo[400]),
	36: GraphicAsset('girl-16','girl', Colors.deepPurple[400]),
	37: GraphicAsset('girl-17','girl', Colors.blue[400]),
	38: GraphicAsset('girl-18','girl', Colors.purple[400]),
	39: GraphicAsset('girl-19','girl', Colors.pink[400])
};

Map<int, GraphicAsset> awardIcons = {
	0: GraphicAsset('gift', 'gift'),
	1: GraphicAsset('backpack', 'activity'),
	2: GraphicAsset('basketball', 'activity'),
	3: GraphicAsset('board-games', 'activity'),
	4: GraphicAsset('bowling', 'activity'),
	5: GraphicAsset('cooking', 'activity'),
	6: GraphicAsset('disco', 'relax'),
	7: GraphicAsset('food', 'food'),
	8: GraphicAsset('ice-cream', 'food'),
	9: GraphicAsset('joystick', 'relax'),
	10: GraphicAsset('movie', 'relax'),
	11: GraphicAsset('park', 'relax'),
	12: GraphicAsset('pizza', 'food'),
	13: GraphicAsset('shopping', 'activity'),
	14: GraphicAsset('sofa', 'relax'),
	15: GraphicAsset('tea', 'food'),
	16: GraphicAsset('ticket', 'relax'),
	17: GraphicAsset('time-planning', 'relax'),
	18: GraphicAsset('walking', 'activity'),
	19: GraphicAsset('woods', 'activity')
};

Map<int, GraphicAsset> badgeIcons = {
	0: GraphicAsset('crown', 'praise'),
	1: GraphicAsset('diploma', 'praise'),
	2: GraphicAsset('thumbs-up', 'praise'),
	3: GraphicAsset('trophy-0', 'trophy'),
	4: GraphicAsset('trophy-1', 'trophy'),
	5: GraphicAsset('trophy-2', 'trophy'),
	6: GraphicAsset('trophy-3', 'trophy'),
	7: GraphicAsset('trophy-4', 'trophy'),
	8: GraphicAsset('trophy-5', 'trophy'),
	9: GraphicAsset('trophy-6', 'trophy'),
	10: GraphicAsset('trophy-7', 'trophy'),
	11: GraphicAsset('trophy-8', 'trophy'),
	12: GraphicAsset('medal-0', 'medal'),
	13: GraphicAsset('medal-1', 'medal'),
	14: GraphicAsset('medal-2', 'medal'),
	15: GraphicAsset('medal-3', 'medal'),
	16: GraphicAsset('medal-4', 'medal'),
	17: GraphicAsset('medal-5', 'medal'),
	18: GraphicAsset('medal-6', 'medal'),
	19: GraphicAsset('medal-7', 'medal')
};
