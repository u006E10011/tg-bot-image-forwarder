import 'package:dotenv/dotenv.dart';
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/tg_bot_image_forwarder.dart';

class ImageForwarderBot {
  Future<void> init() async {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final bot = Bot(env['TOKEN'] as String);
    final data = DataStorage();
    final handler = ImageHandler(bot, data);
    final command = Command(bot, data);

    command.registerCommands();
    handler.registerHandlers();

    await data.loadAsync();

    await bot.start();
  }
}
