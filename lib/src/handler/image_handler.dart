import 'package:televerse/telegram.dart' show ReplyParameters;
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart'
    show MediaHandler, SubscribeHandler, ImageHandlerUtils, DataStorage, MediaModule, MediaType;

class ImageHandler implements MediaHandler {
  @override
  Bot<Context> bot;
  @override
  DataStorage data;

  ImageHandler(this.bot, this.data);

  @override
  Future<void> handleAddAsync(Context ctx, String filter) async {
    try {
      final filterData = MediaModule(
        filter,
        ctx.message!.replyToMessage!.photo!.last.fileId,
        MediaType.image,
        DateTime.now(),
      );

      await data.addAsync(filterData);
      await ctx.reply('Сохранено с фильтром: "$filter"');
    } catch (e) {
      print('Error handling image: $e');
      await ctx.reply('Произошла ошибка при обработке фото');
    }
  }

  @override
  Future<void> sendMediaAsync(Context ctx, MediaModule media) async {
    try {
      await ctx.replyWithPhoto(
        InputFile.fromFileId(media.fileId),
        caption: await bot.isPrivateChat(ctx, false) ? ImageHandlerUtils.captionImage(media) : null,
        replyParameters: ReplyParameters(messageId: ctx.message!.messageId),
      );
    } catch (e) {
      print('Error sending photo by text: $e');
      await ctx.reply('Ошибка при поиске изображения');
      rethrow;
    }
  }

  @override
  bool canHandle(MediaType type) {
    return type == MediaType.image;
  }
}
