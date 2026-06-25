import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/data.dart';

class Command {
  final Bot _bot;
  final Data _data;

  Command(this._bot, this._data);

  void registerCommands() {
    _bot.command('start', startCommandAsync);
    _bot.command('help', helpCommandAsync);
    _bot.command('filter', filterHintCommandAsync);
    _bot.command('filters', getListFiltersCommandAsync);
  }

  Future<void> startCommandAsync(Context ctx) async {
    try {
      await ctx.reply(
        '/start - Информация о боте\n'
        '/help - Помощь\n'
        '/filter <filter_name> - Создать фильтр\n'
        '<filter_name> - Найти изображение по фильтру\n'
        '/filters - Список фильтров',
      );
    } catch (e) {
      print('Error sending list commands: $e');
      await ctx.reply('Ошибка при получения списка комманд');
    }
  }

  Future<void> helpCommandAsync(Context ctx) async {
    try {
      await ctx.reply(
        'Для создания фильтра следует использовать команду:\n /filter <filter_name>',
      );
    } catch (e) {
      print('Error sending list commands: $e');
      await ctx.reply('Ошибка при получения списка фильтров');
    }
  }

  Future<void> filterHintCommandAsync(Context ctx) async {
    try {
      if (ctx.text != null &&
          ctx.text!.replaceAll(' ', '').startsWith('/filter')) {
        if (ctx.text?.length == 7) {
          await ctx.reply(
            "Создать фильтр: /filter <filter_name> и прикрепить изображение",
          );
        } else if (ctx.text!.length > 7 && await ctx.getMessageFile() == null) {
          await ctx.reply('Добавьте изображение');
        }
      }
    } catch (e) {
      await ctx.reply('Ошибка при создании фильтра: $e');
    }
  }

  Future<void> getListFiltersCommandAsync(Context ctx) async {
    try {
      final filters = _data.getListFilters();

      if (filters.isEmpty) {
        await ctx.reply('Нет фильтров');
        return;
      }

      await ctx.reply(filters.join('\n'));
    } catch (e) {
      print('Error sending list commands: $e');
      await ctx.reply('Ошибка при получения списка фильтров');
    }
  }
}
