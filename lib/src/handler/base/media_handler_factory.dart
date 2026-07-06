import 'package:televerse/televerse.dart' show Bot;
import 'package:tg_bot_image_forwarder/image_forwarder.dart';

class MediaHandlerFactory {
  late final Map<MediaType, MediaHandler> _handlers;

  MediaHandlerFactory(Bot bot, DataStorage data)
    : _handlers = {MediaType.image: ImageHandler(bot, data), MediaType.sticker: StickerHandler(bot, data)};

  MediaHandler getHandler(MediaType type) => _handlers[type]!;
}
