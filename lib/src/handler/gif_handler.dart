import 'package:televerse/telegram.dart' show ReplyParameters;
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart' show MediaHandler, DataStorage, MediaModule, MediaType;

class GifHandler implements MediaHandler {
  @override
  Bot<Context> bot;

  @override
  DataStorage data;

  GifHandler(this.bot, this.data);

  @override
  Future<void> handleAddAsync(Context ctx, String filter) async {
    try {
      final filterData = MediaModule(
        filter,
        ctx.message!.replyToMessage!.animation!.fileId,
        MediaType.gif,
        DateTime.now(),
      );
      
      await data.addAsync(filterData);
      await ctx.reply('Сохранено с фильтром: "$filter"');
    } catch (e) {
      print('Error handling GIF: $e');
      await ctx.reply('Произошла ошибка при обработке GIF');
    }
  }

  @override
  Future<void> sendMediaAsync(Context ctx, MediaModule media) async {
    try {
      await ctx.replyWithAnimation(
        InputFile.fromFileId(media.fileId),
        replyParameters: ReplyParameters(messageId: ctx.message!.messageId),
      );
    } catch (e) {
      print('Error sending GIF by text: $e');
      await ctx.reply('Ошибка при поиске GIF');
      rethrow;
    }
  }

  @override
  bool canHandle(MediaType type) {
    return type == MediaType.image;
  }
}
