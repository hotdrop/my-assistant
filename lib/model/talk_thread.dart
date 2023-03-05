class TalkThread {
  const TalkThread({required this.id, required this.title});

  factory TalkThread.createEmpty() {
    return const TalkThread(id: noneId, title: '');
  }

  final int id;
  final String title;

  static const int noneId = -1;

  bool isNotCrerateId() {
    return id == noneId;
  }
}
