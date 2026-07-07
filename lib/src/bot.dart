import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart';

class ImageForwarderBot {
  late Bot _bot;
  late DataStorage _storage;
  late Command _command;
  late MediaHandlerFactory _mediaHandlerFactory;
  late FilterHandler _filterHandler;

  ImageForwarderBot({required String token}) {
    _bot = Bot(token);
    _storage = DataStorage();
    _mediaHandlerFactory = MediaHandlerFactory(_bot, _storage);
    _command = Command(_bot, _storage);
    _filterHandler = FilterHandler(_bot, _storage, _mediaHandlerFactory);
  }

  Future<void> start() async {
    try {
      await _storage.loadAsync();

      _command.registerCommands();
      _filterHandler.register();

      print('Bot started');
      await _bot.start();
    } catch (e, stackTrace) {
      print('Error starting bot: $e');
      print(stackTrace);
      rethrow;
    }
  }

  Future<void> stop() async {
    await _bot.close();
    await _storage.saveAsync();
    print('Bot stopped');
  }
}
