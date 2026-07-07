class MediaModule {
  String filter;
  String fileId;
  MediaType filterType;
  DateTime createdAt;

  MediaModule(this.filter, this.fileId, this.filterType, this.createdAt);

  @override
  String toString() {
    return 'filter: $filter\n'
        'fileId: $fileId\n'
        'filterType: ${filterType.toString()}\n'
        'createdAt: ${formatDate(createdAt)}\n';
  }

  Map<String, dynamic> toJson() {
    return {
      'filter': filter,
      'fileId': fileId,
      'filterType': filterType.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MediaModule.fromJson(Map<String, dynamic> json)
    : filter = json['filter'],
      fileId = json['fileId'],
      filterType = MediaType.values.firstWhere((v) => v.toString() == json['filterType']),
      createdAt = DateTime.parse(json['createdAt']);

  static String formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}';
  }
}

enum MediaType {
  image,
  sticker;

  @override
  String toString() {
    switch (this) {
      case MediaType.image:
        return 'Image';
      case MediaType.sticker:
        return 'Sticker';
    }
  }
}
