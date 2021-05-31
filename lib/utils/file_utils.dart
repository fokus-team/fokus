import 'dart:io';
import 'dart:typed_data';
import 'package:round_spot/round_spot.dart' as round_spot;

import 'package:path_provider/path_provider.dart';

Future saveDebugImage(Uint8List image, round_spot.OutputInfo info) async {
	final path = await _getLocalPath;
	var fileName = '$path/${_getFileName(info)}';
	return File('$fileName.png').writeAsBytes(image);
}

Future saveDebugData(Uint8List data, round_spot.OutputInfo info) async {
	final path = await _getLocalPath;
	var fileName = '$path/raw-${_getFileName(info)}';
	return File('$fileName.json').writeAsBytes(data);
}

String _getFileName(round_spot.OutputInfo info) {
	var pageName = info.page != null ? info.page.substring(1).replaceAll('/', '-') : '';
	var area = info.area.isNotEmpty && !info.isPopup ? '[${info.area}]' : '';
	if (pageName.isNotEmpty)
		area += ' ';
	return '$area$pageName';
}

Future<String> get _getLocalPath async {
	return (await getApplicationDocumentsDirectory()).path;
}
