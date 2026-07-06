import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart';

class Command {
  final Bot _bot;
  final DataStorage _data;
  final FilterImagePreview _filterPreview;

  Command(this._bot, this._data) : _filterPreview = FilterImagePreview(_bot, _data);

  void registerCommands() {
    _bot.command('start', startCommandAsync);
    _bot.command('help', helpCommandAsync);
    _bot.command('filter', filterHintCommandAsync);
    _bot.command('filters', _filterPreview.getPreview);
    _bot.command('remove', removeFilterAsync);
    _bot.command('edit', editFilterAsync);

    _bot.onCallbackQuery(_filterPreview.callbackQueryHandler);
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
        '<filter_name> - Найти изображение по фильтру\n'
        '/filters - Список фильтров',
      );
    } catch (e) {
      print('Error sending help message: $e');
      await ctx.reply('Ошибка при получении помощи');
    }
  }

  Future<void> filterHintCommandAsync(Context ctx) async {
    try {
      if (await _bot.isPublicChat(ctx)) {
        return;
      }

      if (ctx.text != null && ctx.text!.startsWith('/filter')) {
        if (ctx.text?.length == 7) {
          await ctx.reply("Создать фильтр: /filter <filter_name> и прикрепить изображение");
        } else if (ctx.text!.length > 7 && await ctx.getMessageFile() == null) {
          await ctx.reply('Добавьте изображение');
        }
      }
    } catch (e) {
      await ctx.reply('Ошибка при создании фильтра: $e');
    }
  }

  Future<void> removeFilterAsync(Context ctx) async {
    if (ctx.args.isEmpty || await _bot.isPublicChat(ctx)) {
      return;
    }

    if (_data.getListFilters().contains(ctx.args[0])) {
      await _data.removeFilterAsync(ctx.args[0]);
      await ctx.reply('Удалён фильтр: ${ctx.args[0]}');
    } else {
      await ctx.reply('Фильтра "${ctx.args[0]}" не существует. Посмотреть список фильтров /filters');
    }
  }

  Future<void> editFilterAsync(Context ctx) async {
    if (await _bot.isPublicChat(ctx)) {
      return;
    }

    if (ctx.args.length < 2) {
      await ctx.reply('Используйте: /edit <old_filter> <new_filter>');
      return;
    }

    final oldFilter = ctx.args[0];
    final newFilter = ctx.args[1];
    final listFilters = _data.getListFilters();

    if (!listFilters.contains(oldFilter)) {
      await ctx.reply('Фильтр "$oldFilter" не найден');
      return;
    }

    if (listFilters.contains(newFilter)) {
      await ctx.reply('Фильтр "$newFilter" уже существует');
      return;
    }

    try {
      await _data.editFilterAsync(oldFilter, newFilter);
      await ctx.reply('Фильтр "$oldFilter" изменён на "$newFilter"');
    } catch (e) {
      print('Error editing filter: $e');
      await ctx.reply('Произошла ошибка при изменении фильтра');
      rethrow;
    }
  }
}
