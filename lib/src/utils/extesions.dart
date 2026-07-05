import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

extension SubscribeHandler on Bot {
  void subscribeHandler(Filter filter, String logText, Future<void> Function(Context ctx) callback) {
    on(filter, (ctx) async {
      print('$logText: ${ctx.text}');
      await callback(ctx);
    });
  }

  Future<bool> isPrivateChat(Context ctx, [bool sendText = true]) async {
    return !(await isPublicChat(ctx, sendText));
  }

  Future<bool> isPublicChat(Context ctx, [bool sendText = true]) async {
    final isPrivate = ctx.chat?.type == ChatType.private;

    if (isPrivate && sendText) {
      await ctx.reply('Команда ${ctx.command} доступна только в приватном чате');
    }

    return isPrivate;
  }
}
