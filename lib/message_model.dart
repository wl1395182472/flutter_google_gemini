class MyMessage {
  final bool isHuman;
  final MessageType type;
  final String content;

  MyMessage({
    required this.isHuman,
    required this.type,
    required this.content,
  });
}

enum MessageType {
  log,
  normal,
  error,
}
