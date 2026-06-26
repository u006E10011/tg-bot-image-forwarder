import 'dart:math';

class Data {
  Map<String, ImageData> data = {};

  void add(ImageData imageData) {
    if (data.containsKey(imageData.fileId)) {
      print(
        'Exist filter or file id [${imageData.filter}/${imageData.fileId}]',
      );
      return;
    }
    data[imageData.filter] = imageData;
  }

  ImageData? getImage(String filter) {
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
}

class ImageData {
  String filter;
  String fileId;
  int fileSize;
  DateTime createdAt;

  ImageData(this.filter, this.fileId, this.fileSize, this.createdAt);
  
  @override
  String toString() {
    return 'filter: $filter\n'
        'fileId: $fileId\n'
        'fileSize: ${formatBytes(fileSize, 2)}\n'
        'createdAt: ${formatDate(createdAt)}\n';
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}';
  }
}
