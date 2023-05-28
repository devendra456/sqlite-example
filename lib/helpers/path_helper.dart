

import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> getFilePath(String fileName) async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
  String appDocumentsPath = appDocumentsDirectory.path; // 2
  String filePath = '$appDocumentsPath/$fileName'; // 3

  return filePath;
}