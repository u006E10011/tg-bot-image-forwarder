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

  Future<void> getPreview(Context ctx) async {
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
          .text('Список фильтров', 'filter_list');

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
          await getPreview(ctx);
          break;
        case 'filter_list':
          await getListFiltersCommandAsync(ctx);
          break;
        case 'none':
          await ctx.answerCallbackQuery(text: 'Эта кнопка неактивна');
          break;
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

  Future<void> getListFiltersCommandAsync(Context ctx) async {
    try {
      final filters = _data.getListMediaFilters();

      if (filters.isEmpty) {
        await ctx.reply('Нет фильтров');
        return;
      }

      final sorted = _data.data.values.toList()..sort((a, b) => a.filterType.index.compareTo(b.filterType.index));
      final text = sorted.map((x) => '[${x.filterType.toString()}] <code>${x.filter}</code>').join('\n');

      await ctx.reply('Фильтры: ${filters.length}\n$text', parseMode: ParseMode.html);
    } catch (e) {
      print('Error sending list commands: $e');
      try {
        await ctx.reply('Ошибка при получении списка фильтров');
      } catch (replyError) {
        print('Error sending error message: $replyError');
      }
    }
  }
}
