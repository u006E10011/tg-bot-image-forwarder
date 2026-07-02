import 'package:tg_bot_image_forwarder/image_forwarder.dart' show ImageData;

class ImageHandlerUtils {
  static String captionImage(ImageData data) {
    return '''
Фильтр: ${data.filter}
Размер: ${ImageData.formatBytes(data.fileSize, 2)}
Добавлено: ${ImageData.formatDate(data.createdAt)}
''';
  }
}
