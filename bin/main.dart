import 'package:dotenv/dotenv.dart';
import 'package:tg_bot_image_forwarder/image_forwarder.dart';

void main() async {
  try {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final token = env['TOKEN'];

    if (token == null || token.isEmpty) {
      print('Error: TOKEN not found in .env file');
      return;
    }

    final bot = ImageForwarderBot(token: token);
    await bot.start();
  } catch (e) {
    print('Error: $e');
  }
}
