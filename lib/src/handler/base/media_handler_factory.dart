import 'package:televerse/televerse.dart' show Bot;
import 'package:tg_bot_image_forwarder/image_forwarder.dart';
import 'package:tg_bot_image_forwarder/src/handler/gif_handler.dart';

class MediaHandlerFactory {
  late final Map<MediaType, MediaHandler> _handlers;

  MediaHandlerFactory(Bot bot, DataStorage data)
    : _handlers = {MediaType.image: ImageHandler(bot, data), MediaType.sticker: StickerHandler(bot, data),
    MediaType.gif:GifHandler(bot, data)};

  MediaHandler getHandler(MediaType type) => _handlers[type]!;
}