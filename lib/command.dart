import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/data.dart';

class Command {
  final Bot _bot;
  final Data _data;

  Command(this._bot, this._data);

  void registerCommands() {
    _bot.command('start', startCommandAsync);
    _bot.command('help', helpCommandAsync);
    _bot.command('filters', getListFiltersCommandAsync);
  }

  Future<void> startCommandAsync(Context ctx) async {
    try {
      await ctx.reply(
        '/start - Информация о боте\n'
        '/help - Помощь\n'
        '/filters - Список фильтров\n'
        '[filter] - Найти изображение по фильтру',
      );
    } catch (e) {
      print('Error sending list commands: $e');
      await ctx.reply('Ошибка при получения списка комманд');
    }
  }

  Future<void> helpCommandAsync(Context ctx) async {
    try {
      await ctx.reply(
        'Чтобы создать фильтр, нужно отправить изображение с текстовым описанием\n'
        'Чтобы отправить изображение, нужно ввести фильтр [filter]',
      );
    } catch (e) {
      print('Error sending list commands: $e');
      await ctx.reply('Ошибка при получения списка фильтров');
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
