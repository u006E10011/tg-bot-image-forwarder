import 'package:tg_bot_image_forwarder/image_forwarder.dart' show MediaModule;

class ImageHandlerUtils {
  static String captionImage(MediaModule data) {
    return '''
Фильтр: ${data.filter}
Добавлено: ${MediaModule.formatDate(data.createdAt)}
''';
  }
}
