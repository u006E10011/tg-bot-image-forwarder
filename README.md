# tg-bot-image-forwarder

Telegram-бот на Dart, который позволяет сохранять медиа по «имени/фильтру» (изображения и стикеры) и затем отправлять нужное по текстовому запросу.

## Как работает

1. Фильтры создаются командой `/filter <filter_name>` в **ответ** на сообщение с:
   - фото (сохраняется как `MediaType.image`)
   - стикером (сохраняется как `MediaType.sticker`)
2. Имя фильтра используется как ключ (без отдельной логики “caption → фильтр” — используется `replyToMessage`).
3. Если фильтр новый — медиа сохраняется в `data/data_storage.json` (fileId + метаданные).
4. Далее бот слушает обычный текст (без команды) и по **вхождению** имени фильтра в текст отправляет сохранённое медиа.
5. Есть команды для управления фильтрами и просмотра списка.

## Возможности и команды

- `/start` — Информация о боте.
- `/help` — Список доступных команд.
- `/filter <filter_name>` — Создать/задать фильтр, указав команду **в ответ на фото или стикер**.
- `/filters [param]` — Список фильтров (порциями по 10, с inline-кнопками перелистывания).
  - параметры:
    - `-image`, `-img`, `-i` — только изображениях
    - `-sticker`, `-stk`, `-s` — только стикеры
    - `-all`, `-a` — все фильтры
- `/remove <filter_name>` — Удалить фильтр.
- `/edit <old_filter> <new_filter>` — Переименовать фильтр.

### По тексту
Отправка медиа выполняется, когда пользователь присылает текст без команды:
- бот приводит текст к нижнему регистру
- ищет первый фильтр, имя которого встречается в тексте (substring match)
- отправляет сохранённое медиа соответствующего типа (`image`/`sticker`)

## Структура проекта

- `bin/main.dart` — точка входа: чтение `TOKEN` из `.env` и запуск бота.
- `lib/src/bot.dart` — `ImageForwarderBot`: инициализация, загрузка/сохранение `DataStorage`.
- `lib/src/command/command.dart` — регистрации `/start` и `/help`.
- `lib/src/handler/base/filter_handler.dart` — логика команд: `/filter`, `/remove`, `/edit`, `/filters`, а также отправка медиа по тексту.
- `lib/src/handler/image_handler.dart` — добавление/отправка **картинок**.
- `lib/src/handler/sticker_handler.dart` — добавление/отправка **стикеров**.
- `lib/src/handler/base/filter_preview.dart` — UI превью списка фильтров (media group + inline keyboard) и callback.
- `lib/src/service/data_storage.dart` — хранение/загрузка `MediaModule` в `data/data_storage.json`.
- `lib/src/service/delete_message.dart` — удаление сообщений из превью списка.
- `lib/src/module/media_module.dart` — модель данных медиа (`filter`, `fileId`, `filterType`, `createdAt`).

## Конфигурация

### Переменные окружения
В `bin/main.dart` бот ожидает переменную окружения `TOKEN`.
Задаётся через файл `.env` (подключается библиотекой `dotenv`).

Пример `.env`:

```env
TOKEN=123456:ABC-DEF...
```

## Запуск

```bash
git clone https://github.com/u006E10011/tg-bot-image-forwarder.git
cd tg-bot-image-forwarder
dart pub get
dart run bin/main.dart
```

## Хранение данных

Данные о фильтрах и медиа сохраняются в:
- `tg-bot-image-forwarder/data/data_storage.json`

Формат:
- ключ — имя фильтра
- значение — объект `MediaModule`, включая:
  - `filter` — имя фильтра
  - `fileId` — Telegram fileId
  - `filterType` — `Image` или `Sticker`
  - `createdAt` — ISO-строка времени создания

Пример:

```json
{
  "ava": {
    "filter": "ava",
    "fileId": "AgACAgIAAxk...",
    "filterType": "Image",
    "createdAt": "2026-06-28T22:09:37.778435"
  }
}
```


