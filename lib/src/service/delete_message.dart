import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart' show DeleteMessageModule;

class DeleteMessage {
  final Bot _bot;
  late DeleteMessageModule message;

  DeleteMessage(this._bot);

  void register(Context ctx, List<Message> message) {
    this.message = DeleteMessageModule(chatId: ctx.chat!.id, messageId: message.map((msg) => msg.messageId).toList());
  }

  Future<void> deleteMessagesAsync(Context ctx) async {
    try {
      List<Future<void>> query = [];
      for (var messageId in message.messageId) {
        query.add(_bot.api.deleteMessage(ID.create(message.chatId), messageId));
      }
      await Future.wait(query);
    } catch (e) {
      print('Error deleting messages: $e');
    }
  }
}
