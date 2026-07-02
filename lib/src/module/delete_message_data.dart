class DeleteMessageData {
  final int chatId;
  final List<int> messageId;

  DeleteMessageData({required this.chatId, required this.messageId});
}
