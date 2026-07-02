import 'dart:math';

import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/tg_bot_image_forwarder.dart';

class FilterPreview {
  static const int step = 10;

  final DataStorage _data;
  int _currentIndex = 0;

  FilterPreview(this._data);

  Future<void> getPreview(Context ctx) async {
    try {
      final allFilters = _data.getListFilters();

      if (allFilters.isEmpty) {
        await ctx.reply('Нет доступных фильтров');
        return;
      }

      final maxIndex = (allFilters.length / step).ceil() - 1;

      final index = step * _currentIndex;
      final range = (index, min(index + step, allFilters.length));
      final filters = allFilters.getRange(range.$1, range.$2).toList();

      final content = 'Фильтры: ${allFilters.length}\n${TreeFormatter.formatRange(allFilters, range.$1, range.$2)}';
      final keyboard = InlineKeyboard()
          .text(_currentIndex > 0 ? '<< 10' : ' --- ', _currentIndex > 0 ? 'back' : 'none')
          .text(_currentIndex < maxIndex ? '10 >>' : ' --- ', _currentIndex < maxIndex ? 'next' : 'none')
          .row()
          .text('Список фильтров', 'filter_list');

      await ctx.replyWithMediaGroup(
        filters.map((filter) {
          final imageData = _data.getImage(filter);
          if (imageData == null) {
            throw Exception('Image data not found for filter: $filter');
          }
          if (filters[0] == filter) {
            return InputMediaPhoto(media: InputFile.fromFileId(imageData.fileId), caption: content);
          } else {
            return InputMediaPhoto(media: InputFile.fromFileId(imageData.fileId));
          }
        }).toList(),
      );

      await ctx.reply(
        'Фильтры: ${range.$1 + 1}-${range.$2}/${allFilters.length}',
        replyMarkup: keyboard,
        parseMode: ParseMode.html,
      );
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

      final allFilters = _data.getListFilters();

      if (allFilters.isEmpty) {
        await ctx.reply('Нет доступных фильтров');
        return;
      }

      final maxIndex = (allFilters.length / step).ceil() - 1;

      if (ctx.callbackQuery!.data == 'next') {
        _currentIndex = min(_currentIndex + 1, maxIndex);
        await getPreview(ctx);
      } else if (ctx.callbackQuery!.data == 'back') {
        _currentIndex = max(_currentIndex - 1, 0);
        await getPreview(ctx);
      } else if (ctx.callbackQuery!.data == 'filter_list') {
        await getListFiltersCommandAsync(ctx);
      } else if (ctx.callbackQuery!.data == 'none') {
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

  Future<void> getListFiltersCommandAsync(Context ctx) async {
    try {
      final filters = _data.getListFilters();
      final text = TreeFormatter.format(filters);

      if (filters.isEmpty) {
        await ctx.reply('Нет фильтров');
        return;
      }

      await ctx.reply('Фильтры: ${filters.length}\n$text');
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
