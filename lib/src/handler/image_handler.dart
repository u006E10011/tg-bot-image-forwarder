import 'package:televerse/telegram.dart' show ReplyParameters;
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart' show MediaHandler, SubscribeHandler, ImageHandlerUtils, DataStorage, MediaModule, MediaType;

class ImageHander implements MediaHandler {
  @override
  Bot<Context> bot;
  @override
  DataStorage data;

  ImageHander(this.bot, this.data);

  @override
  Future<void> handleAddAsync(Context ctx) async {
    try {
      final text = ctx.caption?.replaceAll(' ', '').toLowerCase();
      final photo = ctx.message?.photo!.last;

      if (photo == null) {
        return;
      }

      if (text == null || text.isEmpty) {
        await ctx.reply('Добавьте название фильтра к изображению');
        return;
      }

      if (data.getListFilters().contains(text)) {
        await ctx.reply('Фильтр "$text" уже существует');
        await sendMediaAsync(ctx, text);

        return;
      }

      final filterData = MediaModule(text, photo.fileId, MediaType.image, DateTime.now());

      await data.addAsync(filterData);
      await ctx.reply('Сохранено с фильтром: "$text"');
    } catch (e) {
      print('Error handling image: $e');
      await ctx.reply('Произошла ошибка при обработке фото');
    }
  }

  @override
  Future<void> handleSendAsync(Context ctx) async {
    final text = ctx.text?.replaceAll(' ', '').toLowerCase();
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
      await ctx.reply('Фильтр "$text" не найден. Используйте /filters для просмотра списка');
      return;
    }

    await sendMediaAsync(ctx, targetFilter);
  }

  @override
  Future<void> sendMediaAsync(Context ctx, String filter) async {
    try {
      final imageData = data.getImage(filter)!;
      final image = InputFile.fromFileId(imageData.fileId);

      await ctx.replyWithPhoto(
        image,
        caption: await bot.isPrivateChat(ctx, false) ? ImageHandlerUtils.captionImage(imageData) : null,
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
