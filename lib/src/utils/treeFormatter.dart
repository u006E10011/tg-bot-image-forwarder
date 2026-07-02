class TreeFormatter {
  static String format(List<String> content) {
    if (content.isEmpty) {
      return '';
    }

    String text = '';

    for (int i = 0; i < content.length - 1; i++) {
      text += '├── ${i + 1}: ${content[i]}\n';
    }

    text += '└── ${content.length}: ${content[content.length - 1]}';
    return text;
  }

  static String formatRange(List<String> content, int start, int end) {
    if (content.isEmpty) {
      return '';
    }
    List<String> filteredContent = content.sublist(start, end.clamp(0, content.length));
    String text = '';

    for (int i = start; i < end - 1 && i < content.length; i++) {
      text += '├── ${i + 1}: ${content[i]}\n';
    }

    text += '└── $end: ${filteredContent[filteredContent.length - 1]}';
    return text;
  }
}
