import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future saveDebugImage(Uint8List image) async {
	final path = await _getLocalPath;
	var file = File('$path/${DateTime.now()}.png');
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
