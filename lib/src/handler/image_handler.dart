import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart';

class ImageHandler {
  final Bot _bot;
  final DataStorage _data;

  ImageHandler(this._bot, this._data);

  void registerHandlers() {
    print('Registering handlers...');

    _subscribeHandler(
      _bot.filters.privateChat * _bot.filters.photo * _bot.filters.caption,
      '📸 Photo with text received',
      _handleAddImageAsync,
    );

    _subscribeHandler(
      _bot.filters.privateChat * _bot.filters.photo - _bot.filters.caption,
      '📸 Photo with text received',
      (ctx) => ctx.reply('Добавьте фильтр к изображению'),
    );

    _subscribeHandler(
      _bot.filters.text - _bot.filters.command,
      '📝 Text received',
      _handleSendImageAsync,
    );
  }

  Future<void> _handleAddImageAsync(Context ctx) async {
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

      if (_data.getListFilters().contains(text)) {
        await ctx.reply('Фильтр "$text" уже существует');
        await _sendImageAsync(ctx, text);

        return;
      }

      final imageData = ImageData(
        text,
        photo.fileId,
        photo.fileSize!,
        DateTime.now(),
      );

      await _data.addAsync(imageData);

      await ctx.reply('Сохранено с фильтром: "$text"');
    } catch (e) {
      print('Error handling image: $e');
      await ctx.reply('Произошла ошибка при обработке фото');
    }
  }

  Future<void> _handleSendImageAsync(Context ctx) async {
    final filter = ctx.text?.replaceAll(' ', '').toLowerCase();

    if (filter == null || filter.isEmpty) {
      return;
    }

    await _sendImageAsync(ctx, filter);
  }

  Future<void> _sendImageAsync(Context ctx, String filter) async {
    try {
      final imageData = _data.getImage(filter);

      if (imageData == null) {
        await ctx.reply(
          'Фильтр "$filter" не найден. Используйте /filters для списка',
        );
        return;
      }

      final image = InputFile.fromFileId(imageData.fileId);
      print(imageData.toString());

      await ctx.replyWithPhoto(
        image,
        caption:
            'Фильтр: $filter\n'
            'Размер: ${ImageData.formatBytes(imageData.fileSize, 2)}\n'
            'Добавлено: ${ImageData.formatDate(imageData.createdAt)}',
      );
    } catch (e) {
      print('Error sending photo by text: $e');
      await ctx.reply('Ошибка при поиске фото');
      rethrow;
    }
  }

  void _subscribeHandler(
    Filter<Context> filter,
    String logText,
    Function(Context) callback,
  ) {
    _bot.on(filter, (ctx) async {
      print('$logText: ${ctx.text}');
      await callback(ctx);
    });
  }
}
