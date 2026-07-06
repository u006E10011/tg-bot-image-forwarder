import 'dart:convert';
import 'dart:io' as io;
import 'package:path/path.dart' as path;
import 'package:tg_bot_image_forwarder/image_forwarder.dart';

class DataStorage {
  static const String folder = 'data';
  static const String fileName = 'data_storage.json';

  late String _filePath;
  Map<String, MediaModule> data = {};

  Future<void> addAsync(MediaModule imageData) async {
    if (data.containsKey(imageData.fileId)) {
      print('Exist filter or file id [${imageData.filter}/${imageData.fileId}]');
      return;
    }

    data[imageData.filter] = imageData;
    await saveAsync();
  }

  MediaModule? getImage(String filter) {
    if (data.containsKey(filter)) {
      return data[filter]!;
    }

    return null;
  }

  List<String> getListFilters() {
    if (data.isNotEmpty) {
      return data.keys.toList();
    }
    return [];
  }

  Future<void> removeFilterAsync(String filter) async {
    if (data.containsKey(filter)) {
      data.remove(filter);
      await saveAsync();
    }
  }

  Future<void> editFilterAsync(String oldFilter, String newFilter) async {
    if (data.containsKey(oldFilter) && !data.containsKey(newFilter)) {
      final imageData = data[oldFilter]!;
      data.remove(oldFilter);
      imageData.filter = newFilter;
      data[newFilter] = imageData;
      await saveAsync();
    }
  }

  void _initStorage() {
    final currentDir = io.Directory.current.path;
    final dataDir = path.join(currentDir, folder);
    final dir = io.Directory(dataDir);

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      print('📁 Created data directory: $dataDir');
    }

    _filePath = path.join(dataDir, fileName);
    print('📂 Storage path: $_filePath');
  }

  Future<void> saveAsync() async {
    try {
      final jsonMap = data.map((key, value) => MapEntry(key, (value as dynamic).toJson()));
      final file = io.File(_filePath);
      final prettyJson = JsonEncoder.withIndent('  ').convert(jsonMap);
      await file.writeAsString(prettyJson, encoding: utf8);
    } catch (e) {
      print('Error save data $_filePath: $e');
      rethrow;
    }
  }

  Future<void> loadAsync() async {
    try {
      _initStorage();

      final file = io.File(_filePath);

      if (!await file.exists()) {
        print('File not found, starting with empty data');
        data = {};
        return;
      }

      final json = await file.readAsString(encoding: utf8);
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      data = decoded.map((key, value) => MapEntry(key, MediaModule.fromJson(value)));
    } on io.PathNotFoundException {
      print('File not found, starting with empty data');
      data = {};
    } catch (e) {
      print('Error loading data from $_filePath: $e');
      data = {};
      rethrow;
    }
  }
}
