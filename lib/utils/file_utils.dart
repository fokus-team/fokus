import 'dart:io';
import 'dart:typed_data';
import 'package:round_spot/round_spot.dart' as round_spot;

import 'package:path_provider/path_provider.dart';

Future saveDebugImage(Uint8List image, [round_spot.OutputInfo info]) async {
	final path = await _getLocalPath;
	var pageName = info.page != null ? info.page.substring(1).replaceAll('/', '-') : '';
	var area = info.area.isNotEmpty ? '[${info.area}]' : '';
	if (pageName.isNotEmpty)
		area += ' ';
	var fileName = '$path/$area$pageName';
	var file = File('$fileName.png');
	if (file.existsSync())
		file = File('$fileName-1.png');
	return file.writeAsBytes(image);
}

Future saveDebugData(String data) async {
	final path = await _getLocalPath;
	var file = File('$path/${DateTime.now()}.json');
	return file.writeAsString(data);
}

Future<String> get _getLocalPath async {
	return (await getApplicationDocumentsDirectory()).path;
}
