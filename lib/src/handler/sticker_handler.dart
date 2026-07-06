import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart' show MediaHandler;
import 'package:tg_bot_image_forwarder/src/module/media_module.dart';
import 'package:tg_bot_image_forwarder/src/service/data_storage.dart';

class StickerHandler implements MediaHandler {
  @override
  Bot<Context> bot;

  @override
  DataStorage data;

  StickerHandler(this.bot, this.data);

  @override
  Future<void> handleAddAsync(Context ctx) {
    // TODO: implement handleAddAsync
    throw UnimplementedError();
  }

  @override
  Future<void> handleSendAsync(Context ctx) {
    // TODO: implement handleSendAsync
    throw UnimplementedError();
  }

  @override
  Future<void> sendMediaAsync(Context ctx, String filter) {
    // TODO: implement sendMediaAsync
    throw UnimplementedError();
  }

    @override
  bool canHandle(MediaType type) {
    throw UnimplementedError();
  }
}