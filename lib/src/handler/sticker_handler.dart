import 'package:televerse/telegram.dart' show ReplyParameters;
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart'
    show MediaHandler, SubscribeHandler, DataStorage, MediaModule, MediaType;

class StickerHandler implements MediaHandler {
  @override
  Bot<Context> bot;

  @override
  DataStorage data;

  StickerHandler(this.bot, this.data);

  @override
  Future<void> handleAddAsync(Context ctx) async {
    final text = ctx.args[0].toLowerCase();

    try {
      if (data.getListFilters().contains(text)) {
        await ctx.reply('Фильтр "$text" уже существует');
        await sendMediaAsync(ctx, text);

        return;
      }

      final filterData = MediaModule(
        text,
        ctx.message!.replyToMessage!.sticker!.fileId,
        MediaType.image,
        DateTime.now(),
      );

      await data.addAsync(filterData);
      await ctx.reply('Сохранено с фильтром: "$text"');
    } catch (e) {
      print('Error handling image: $e');
      await ctx.reply('Произошла ошибка при обработке стикера');
    }
  }

  @override
  Future<void> handleSendAsync(Context ctx) async {
    final text = ctx.text?.toLowerCase();
    var targetFilter = '';
    if (text == null || text.isEmpty) {
      return;
    }

    for (String filter in data.getListFilters()) {
      if (text.contains(filter)) {
        targetFilter = filter;
      }
    }

    if (await bot.isPublicChat(ctx, false) && targetFilter.isEmpty) {
      return;
    }

    if (await bot.isPrivateChat(ctx, false) && targetFilter.isEmpty) {
      await ctx.reply('Фильтр "$text" не найден');
      return;
    }

    await sendMediaAsync(ctx, targetFilter);
  }

  @override
  Future<void> sendMediaAsync(Context ctx, String filter) async {
    try {
      final media = data.getMedia(filter)!;
      final sticker = InputFile.fromFileId(media.fileId);

      await ctx.replyWithSticker(sticker, replyParameters: ReplyParameters(messageId: ctx.message!.messageId));
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
