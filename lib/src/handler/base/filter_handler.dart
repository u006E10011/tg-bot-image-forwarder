// ignore_for_file: unrelated_type_equality_checks

import 'package:televerse/televerse.dart' show Bot, Context, ContextAwareMethods;
import 'package:tg_bot_image_forwarder/image_forwarder.dart' show MediaHandlerFactory, SubscribeHandler;
import 'package:tg_bot_image_forwarder/src/module/media_module.dart' show MediaType;
import 'package:tg_bot_image_forwarder/src/service/data_storage.dart' show DataStorage;

class FilterHandler {
  final Bot bot;
  final DataStorage data;
  final MediaHandlerFactory handler;

  FilterHandler(this.bot, this.data, this.handler);

  void register() {
    bot.subscribeHandler(bot.filters.cmd('filter'), '[CreateFilter]', createFilterAsync);
    bot.subscribeHandler(bot.filters.text, '[SendMedia]', handleSendMediaAsync);
  }

  Future<void> createFilterAsync(Context ctx) async {
    try {
      if (await bot.isPublicChat(ctx)) {
        return;
      }

      if (ctx.text?.length == 7) {
        await ctx.reply("Создать фильтр: /filter <filter_name>");
      } else if (ctx.text!.length > 7) {
        final replyMsg = ctx.message?.replyToMessage;
        final filter = ctx.argsString!.toLowerCase();

        if (replyMsg != null) {
          if (data.getListFiltersByType(MediaType.image).contains(filter)) {
            final media = data.getMedia(filter)!;
            await ctx.reply('Фильтр "$filter" уже существует');
            await handler.getHandler(media.filterType).sendMediaAsync(ctx, media);

            return;
          }

          switch (replyMsg) {
            case var msg when msg.photo != null:
              print('Photo ${msg.photo!.last.fileId}');
              await handler.getHandler(MediaType.image).handleAddAsync(ctx, filter);
            case var msg when msg.sticker != null:
              await handler.getHandler(MediaType.sticker).handleAddAsync(ctx, filter);
          }
        }
      }
    } catch (e) {
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
      switch (media.filterType) {
        case MediaType.image:
          await handler.getHandler(MediaType.image).sendMediaAsync(ctx, media);
          break;
        case MediaType.sticker:
          await handler.getHandler(MediaType.sticker).sendMediaAsync(ctx, media);
          break;
      }
    } catch (e) {
      print('Error sending media: $e');
      await ctx.reply('Произошла ошибка при отправке медиа: [${media.filterType.toString()}] $targetFilter');
    }
  }
}
