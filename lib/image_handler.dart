import 'dart:io';

import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/data.dart';

class Handler {
  final Bot _bot;
  final Data _data;

  Handler(this._bot, this._data);

  void registerHandlers() {
    print('Registering handlers...');

    _subscribeHandler(
      _bot.filters.privateChat * _bot.filters.photo * _bot.filters.caption,
      '📸 Photo with text received',
      _handleImageAsync,
    );

    _subscribeHandler(
      _bot.filters.photo - _bot.filters.caption,
      '📸 Photo with text received',
      (ctx) => ctx.reply('Добавьте фильтр к изображению'),
    );

    _subscribeHandler(_bot.filters.text - _bot.filters.command,
      '📝 Text received',
      _handleSendImageAsync,
    );
  }

  Future<void> _handleImageAsync(Context ctx) async {
    try {
      final text = ctx.caption?.replaceAll(' ', '').toLowerCase();
      final photo = await ctx.getMessageFile();

      if (photo == null) {
        return;
      }
      if (text == null || text.isEmpty) {
        await ctx.reply('Добавьте название фильтра к изображению');
        return;
      }

      final imageData = ImageData(
        text,
        photo.fileId,
        photo.fileSize!,
        DateTime.now(),
      );

      _data.add(imageData);

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

    try {
      final imageData = _data.getImage(filter);

      if (imageData == null && ctx.chat?.type == ChatType.private) {
        ctx.reply(
          'Фильтр "$filter" не найден. Используйте /filters для списка',
        );
        return;
      } else if (imageData == null) {
        return;
      }

      final file = await _bot.api.getFile(imageData.fileId);
      final downloaded = await file.download(token: _bot.token, path: '../img');

      if (downloaded == null) {
        await ctx.reply('Не удалось загрузить файл');
        return;
      }

      final photo = InputFile.fromFile(downloaded);

      await ctx.replyWithPhoto(
        photo,
        caption:
            'Фильтр: $filter\n'
            'Размер: ${ImageData.formatBytes(imageData.fileSize, 2)}\n'
            'Добавлено: ${_formatDate(imageData.createdAt)}',
      );
    } catch (e) {
      print('Error sending photo by text: $e');
      await ctx.reply('Ошибка при поиске фото');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}';
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
