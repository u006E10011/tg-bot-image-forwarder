// ignore_for_file: pattern_never_matches_value_type, unrelated_type_equality_checks

import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart' show Bot, Context, ContextAwareMethods, InlineKeyboard;
import 'package:tg_bot_image_forwarder/image_forwarder.dart'
    show MediaHandlerFactory, SubscribeHandler, FilterImagePreview, MediaType, DataStorage;

class FilterHandler {
  final Bot bot;
  final DataStorage data;
  final MediaHandlerFactory handler;
  final FilterImagePreview _filterPreview;

  FilterHandler(this.bot, this.data, this.handler) : _filterPreview = FilterImagePreview(bot, data);

  void register() {
    bot.subscribeHandler(bot.filters.cmd('filter'), '[CREATE]', createFilterAsync);
    bot.subscribeHandler(
      bot.filters.text - (bot.filters.command + bot.filters.callbackQuery),
      '[SEND]',
      handleSendMediaAsync,
    );
    bot.subscribeHandler(bot.filters.cmd('edit'), '[EDIT]', editFilterAsync);
    bot.subscribeHandler(bot.filters.cmd('remove'), '[REMOVE]', removeFilterAsync);
    bot.subscribeHandler(bot.filters.cmd('filters'), '[FILTERS]', getListFilterAsync);

    bot.onCallbackQuery(_filterPreview.callbackQueryHandler);
  }

  Future<void> createFilterAsync(Context ctx) async {
    try {
      if (await bot.isPublicChat(ctx)) {
        return;
      }

      if (ctx.args.isNotEmpty) {
        final replyMsg = ctx.message?.replyToMessage;
        final filter = ctx.argsString!.toLowerCase();

        if (replyMsg != null) {
          if (data.exist(filter)) {
            final media = data.getMedia(filter)!;
            await ctx.reply('Фильтр "$filter" уже существует');
            await handler.getHandler(media.filterType).sendMediaAsync(ctx, media);

            return;
          }

          switch (replyMsg) {
            case var msg when msg.photo != null:
              await handler.getHandler(MediaType.image).handleAddAsync(ctx, filter);
            case var msg when msg.sticker != null:
              await handler.getHandler(MediaType.sticker).handleAddAsync(ctx, filter);
            case var msg when msg.animation != null:
              await handler.getHandler(MediaType.gif).handleAddAsync(ctx, filter);
          }
        }
      } else {
        await ctx.reply("Создать фильтр: /filter <filter_name>");
      }
    } catch (e) {
      print('Error when creating filter: $e');
      await ctx.reply('Ошибка при создании фильтра: $e');
    }
  }

  Future<void> handleSendMediaAsync(Context ctx) async {
    final text = ctx.text?.toLowerCase();
    String? targetFilter;

    if (text == null || text.isEmpty) {
      return;
    }

    for (String filter in data.getListMediaFilters()) {
      if (text.contains(filter)) {
        targetFilter = filter;
        break;
      }
    }

    switch (targetFilter) {
      case null when await bot.isPublicChat(ctx, false) == true:
        return;
      case null when await bot.isPrivateChat(ctx, false) == true:
        await ctx.reply('Фильтр не найден. Используйте /filters для просмотра доступных фильтров');
        return;
    }

    final media = data.getMedia(targetFilter!)!;

    try {
      await handler.getHandler(media.filterType).sendMediaAsync(ctx, media);
    } catch (e) {
      print('Error sending media: $e');
      await ctx.reply('Произошла ошибка при отправке медиа: [${media.filterType.toString()}] $targetFilter');
    }
  }

  Future<void> removeFilterAsync(Context ctx) async {
    if (ctx.args.isEmpty || await bot.isPublicChat(ctx)) {
      return;
    }

    if (data.getListMediaFilters().contains(ctx.args[0])) {
      await data.removeFilterAsync(ctx.args[0]);
      await ctx.reply('Удалён фильтр: ${ctx.args[0]}');
    } else {
      await ctx.reply('Фильтра "${ctx.args[0]}" не существует. Посмотреть список фильтров /filters');
    }
  }

  Future<void> editFilterAsync(Context ctx) async {
    if (await bot.isPublicChat(ctx)) {
      return;
    }

    if (ctx.args.length < 2) {
      await ctx.reply('Используйте: /edit <old_filter> <new_filter>');
      return;
    }

    final oldFilter = ctx.args[0];
    final newFilter = ctx.args[1];
    final listFilters = data.getListMediaFilters();

    if (!listFilters.contains(oldFilter)) {
      await ctx.reply('Фильтр "$oldFilter" не найден');
      return;
    }

    if (listFilters.contains(newFilter)) {
      await ctx.reply('Фильтр "$newFilter" уже существует');
      return;
    }

    try {
      await data.editFilterAsync(oldFilter, newFilter);
      await ctx.reply('Фильтр "$oldFilter" изменён на "$newFilter"');
    } catch (e) {
      print('Error editing filter: $e');
      await ctx.reply('Произошла ошибка при изменении фильтра');
      rethrow;
    }
  }

  Future<void> getListFilterAsync(Context ctx) async {
    try {
      await switch (ctx.args.firstOrNull ?? '') {
        '-image' || '-img' || '-i' => _filterPreview.getListFilterByType(ctx, MediaType.image),
        '-sticker' || '-stk' || '-s' => _filterPreview.getListFilterByType(ctx, MediaType.sticker),
        '-gif' || '-g' => _filterPreview.getListFilterByType(ctx, MediaType.gif),
        '-all' || '-a' => _filterPreview.getListFilterByType(ctx, MediaType.all),
        _ => ctx.reply(
          '<b>Доступные параметры /filters</b>\n\n'
          '<b>Изображения:</b> <code>-image</code>, <code>-img</code>, <code>-i</code>\n'
          '<b>Стикеры:</b> <code>-sticker</code>, <code>-stk</code>, <code>-s</code>\n'
          '<b>Все фильтры:</b> <code>-all</code>, <code>-a</code>\n\n'
          '<i>Пример:</i> <code>/filters -all</code>',
          parseMode: ParseMode.html,
          replyMarkup: InlineKeyboard()
              .text('Image', 'filter_image')
              .text('Sticker', 'filter_sticker')
              .text('GIF', 'filter_gif')
              .row()
              .text('All', 'filter_all'),
        ),
      };
    } catch (e) {
      print("Error send filter list [${ctx.argsString}]\n$e");
      rethrow;
    }
  }
}
