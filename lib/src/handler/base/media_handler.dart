import 'package:televerse/telegram.dart' show Message;
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart' show MediaType, DataStorage;

abstract class MediaHandler {
  late final Bot bot;
  late final DataStorage data;

  Future<void> handleAddAsync(Context ctx);
  Future<void> handleSendAsync(Context ctx);
  Future<void> sendMediaAsync(Context ctx, String filter);
  bool canHandle(MediaType type);
}
