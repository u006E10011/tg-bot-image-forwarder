import 'package:televerse/televerse.dart';

class Command {
  final Bot _bot;

  Command(this._bot);

  void registerCommands() {
    _bot.command('start', startCommandAsync);
    _bot.command('help', helpCommandAsync);
  }

  Future<void> startCommandAsync(Context ctx) async {
    try {
      await ctx.reply(
        'Bot: ${_bot.botInfo.me!.firstName}/@${_bot.me.username}\n'
        'Developer: он .rar/@ryadevn\n',
      );
    } catch (e) {
      print('Error sending start message: $e');
    }
  }

  Future<void> helpCommandAsync(Context ctx) async {
    try {
      await ctx.reply(
        '/start - Информация о боте\n'
        '/help - Помощь\n'
        '/filter <filter_name> - Создать фильтр\n'
        '/remove <filter_name> - Удалить фильтр\n'
        '/edit <old_filter_name> <new_filter_name> - Изменить фильтр\n'
        '<filter_name> - Поиск медиа по фильтру\n'
        '/filters - Список фильтров',
      );
    } catch (e) {
      print('Error sending help message: $e');
      await ctx.reply('Ошибка при получении помощи');
    }
  }
}
