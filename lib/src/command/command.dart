import 'package:televerse/telegram.dart' show ParseMode;
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
      await ctx.reply('''
Позволяет сохранять медиа по «имени/фильтру» и затем отправлять по текстовому запросу.

1. Фильтры создаются командой `/filter <filter_name>` в **ответ** на сообщение с:
   - фото (сохраняется как `MediaType.image`)
   - стикером (сохраняется как `MediaType.sticker`)
   - GIF (сохраняется как `MediaType.gif`)
2. Имя фильтра используется как ключ.
3. Медиа сохраняется в `data/data_storage.json` (fileId + метаданные).
4. Далее бот парсит текст и по **вхождению** имени фильтра в текст отправляет сохранённое медиа.
5. Есть команды для управления фильтрами и просмотра списка.
''', parseMode: ParseMode.markdown);
    } catch (e) {
      print('Error sending start message: $e');
    }
  }

  Future<void> helpCommandAsync(Context ctx) async {
    try {
      await ctx.reply('''
`/start` — Информация о боте
`/help` — Список доступных команд
`/filter <filter_name>` — Создать/задать фильтр, указав команду **в ответ на фото или стикер**
`/filters [param]` — Список фильтров (порциями по 10, с inline-кнопками перелистывания)
    `-image`, `-img`, `-i` — только изображениях
    `-sticker`, `-stk`, `-s` — только стикеры
    `-gif`, `-g` — только GIF
    `-all`, `-a` — все фильтры
`/remove <filter_name>` — Удалить фильтр
`/edit <old_filter> <new_filter>` — Переименовать фильтр
''', parseMode: ParseMode.markdown);
    } catch (e) {
      print('Error sending help message: $e');
      await ctx.reply('Ошибка при получении помощи');
    }
  }
}
