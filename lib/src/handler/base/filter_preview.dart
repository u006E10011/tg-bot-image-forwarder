import 'dart:math';

import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart';

class FilterImagePreview {
  static const int step = 10;

  final DataStorage _data;
  final DeleteMessage _deleteMessage;
  int _currentIndex = 0;

  FilterImagePreview(Bot bot, this._data) : _deleteMessage = DeleteMessage(bot);

  Future<void> getImagePreview(Context ctx) async {
    try {
      await _deleteMessage.deleteMessagesAsync(ctx);

      final allFilters = _data.getListFiltersByType(MediaType.image);

      if (allFilters.isEmpty) {
        await ctx.reply('Нет доступных фильтров');
        return;
      }

      final maxIndex = (allFilters.length / step).ceil() - 1;
      final index = step * _currentIndex;
      final range = (index, min(index + step, allFilters.length));
      final filters = allFilters.getRange(range.$1, range.$2).toList();

      final content =
          'Фильтры (image/sticker/total): ${allFilters.length}/${_data.getListFiltersByType(MediaType.sticker).length}/${_data.getListMediaFilters().length}\n${TreeFormatter.formatRange(allFilters, range.$1, range.$2)}';
      final keyboard = InlineKeyboard()
          .text(_currentIndex > 0 ? '<< 10' : ' --- ', _currentIndex > 0 ? 'back' : 'none')
          .text(_currentIndex < maxIndex ? '10 >>' : ' --- ', _currentIndex < maxIndex ? 'next' : 'none')
          .row()
          .text('Список фильтров', 'filter_image');

      var mediaGroupMessage = await ctx.replyWithMediaGroup(
        filters.map((filter) {
          final imageData = _data.getMedia(filter);
          if (imageData == null) {
            throw Exception('Image data not found for filter: $filter');
          }
          return InputMediaPhoto(
            media: InputFile.fromFileId(imageData.fileId),
            caption: filters[0] == filter ? content : null,
          );
        }).toList(),
      );

      var keyboardMessage = await ctx.reply(
        'Фильтры: ${range.$1 + 1}-${range.$2}/${allFilters.length}',
        replyMarkup: keyboard,
        parseMode: ParseMode.html,
      );

      _deleteMessage.register(ctx, <Message>[...mediaGroupMessage, keyboardMessage]);
    } catch (e, stackTrace) {
      print('Error in getPreview: $e');
      print('StackTrace: $stackTrace');
      try {
        await ctx.reply('Произошла ошибка при загрузке фильтров. Пожалуйста, попробуйте позже.');
      } catch (replyError) {
        print('Error sending error message: $replyError');
      }
    }
  }

  Future<void> callbackQueryHandler(Context ctx) async {
    try {
      await ctx.answerCallbackQuery(text: 'Загрузка...');

      final allFilters = _data.getListFiltersByType(MediaType.image);

      if (allFilters.isEmpty) {
        await ctx.reply('Нет доступных фильтров');
        return;
      }

      final maxIndex = (allFilters.length / step).ceil() - 1;

      switch (ctx.callbackQuery!.data) {
        case var data when data == 'next' || data == 'back':
          _currentIndex = min(_currentIndex + (data == 'next' ? 1 : -1), maxIndex);
          await getImagePreview(ctx);
        case 'filter_image_preview':
          await getImagePreview(ctx);
        case 'filter_image':
          await getListFilterByType(ctx, MediaType.image);
        case 'filter_sticker':
          await getListFilterByType(ctx, MediaType.sticker);
        case 'filter_gif':
          await getListFilterByType(ctx, MediaType.gif);
        case 'filter_all':
          await getListFilterByType(ctx, MediaType.all);
        case 'none':
          await ctx.answerCallbackQuery(text: 'Эта кнопка неактивна');
      }
    } catch (e, stackTrace) {
      print('Error in callbackQueryHandler: $e');
      print('StackTrace: $stackTrace');
      try {
        await ctx.answerCallbackQuery(text: 'Произошла ошибка', showAlert: true);
      } catch (answerError) {
        print('Error answering callback: $answerError');
      }
    }
  }

  Future<void> getListFilterByType(Context ctx, MediaType media) async {
    try {
      if (_data.data.isEmpty) {
        await ctx.reply('Нет фильтров');
        return;
      }

      final sorted = _data.data.values.where((x) {
        if (media == MediaType.all) {
          return x.filterType != MediaType.all;
        }
        return x.filterType == media;
      });
      final text = sorted.map((x) => '[${x.filterType.toString()}] <code>${x.filter}</code>').join('\n');

      await ctx.reply(
        'Фильтры: ${sorted.length}\n$text',
        parseMode: ParseMode.html,
        replyMarkup: media == MediaType.image ? InlineKeyboard().text("Предосмотр", 'filter_image_preview') : null,
      );
    } catch (e) {
      print('Error sending list commands: $e');
      try {
        await ctx.reply('Ошибка при получении списка фильтров [$media]');
      } catch (replyError) {
        print('Error sending error message: $replyError');
      }
    }
  }
}
