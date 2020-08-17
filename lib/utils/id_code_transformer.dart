import 'package:mongo_dart/mongo_dart.dart';

ObjectId getIdFromCode(String code) => ObjectId.parse(code);
String getCodeFromId(ObjectId id) => id.toHexString();
