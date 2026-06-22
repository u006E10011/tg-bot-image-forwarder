import 'package:dotenv/dotenv.dart';
import 'package:televerse/televerse.dart';
import 'package:tg_bot_image_forwarder/command.dart';
import 'package:tg_bot_image_forwarder/image_handler.dart';
import 'package:tg_bot_image_forwarder/data.dart';

void main() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final bot = Bot(env['TOKEN'] as String);
  final data = Data();
  final handler = Handler(bot, data);
  final command = Command(bot, data);

  command.registerCommands();
  handler.registerHandlers();
  await bot.start();
}
