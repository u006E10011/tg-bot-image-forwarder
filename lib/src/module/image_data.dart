import 'dart:math';

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

  Map<String, dynamic> toJson() {
    return {
      'filter': filter,
      'fileId': fileId,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ImageData.fromJson(Map<String, dynamic> json)
    : filter = json['filter'],
      fileId = json['fileId'],
      fileSize = json['fileSize'],
      createdAt = DateTime.parse(json['createdAt']);

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
