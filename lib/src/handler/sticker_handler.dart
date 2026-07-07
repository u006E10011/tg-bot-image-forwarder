import 'package:televerse/telegram.dart' show ReplyParameters;
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart' show MediaHandler, DataStorage, MediaModule, MediaType;

class StickerHandler implements MediaHandler {
  @override
  Bot<Context> bot;

  @override
  DataStorage data;

  StickerHandler(this.bot, this.data);

  @override
  Future<void> handleAddAsync(Context ctx, String filter) async {
    try {
      final filterData = MediaModule(
        filter,
        ctx.message!.replyToMessage!.sticker!.fileId,
        MediaType.sticker,
        DateTime.now(),
      );

      await data.addAsync(filterData);
      await ctx.reply('Сохранено с фильтром: "$filter"');
    } catch (e) {
      print('Error handling sticker: $e');
      await ctx.reply('Произошла ошибка при обработке стикера');
    }
  }

  @override
  Future<void> sendMediaAsync(Context ctx, MediaModule media) async {
    try {
      await ctx.replyWithSticker(
        InputFile.fromFileId(media.fileId),
        replyParameters: ReplyParameters(messageId: ctx.message!.messageId),
      );
    } catch (e) {
      print('Error sending sticker by text: $e');
      await ctx.reply('Ошибка при поиске стикера');
      rethrow;
    }
  }

  @override
  bool canHandle(MediaType type) {
    return type == MediaType.image;
  }
}
