import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart' show DataStorage, MediaModule, MediaType;

abstract class MediaHandler {
  late final Bot bot;
  late final DataStorage data;

  Future<void> handleAddAsync(Context ctx, String filter);
  Future<void> sendMediaAsync(Context ctx, MediaModule media);
  bool canHandle(MediaType type);
}
