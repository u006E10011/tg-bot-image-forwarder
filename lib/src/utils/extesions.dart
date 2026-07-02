import 'package:televerse/televerse.dart';

extension SubscribeHandler on Bot {
  subscribeHandler(Filter filter, String logText, Future<void> Function(Context ctx) callback) {
    this.on(filter, (ctx) async {
      print('$logText: ${ctx.text}');
      await callback(ctx);
    });
  }
}
