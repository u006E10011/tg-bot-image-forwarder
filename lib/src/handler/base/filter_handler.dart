import 'package:televerse/televerse.dart' show Bot;
import 'package:tg_bot_image_forwarder/image_forwarder.dart' show MediaHandlerFactory, SubscribeHandler;
import 'package:tg_bot_image_forwarder/src/module/media_module.dart' show MediaType;

class FilterHandler {
  void register(Bot bot, MediaHandlerFactory handler) {
    bot.subscribeHandler(bot.filters.text, 'Photo', handler.getHandler(MediaType.image).handleSendAsync);
    bot.subscribeHandler(bot.filters.text, 'Photo', handler.getHandler(MediaType.sticker).handleSendAsync);
  }
}
