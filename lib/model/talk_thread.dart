class TalkThread {
  const TalkThread({required this.id, required this.title, required this.talkNum});

  factory TalkThread.createEmpty() {
    return const TalkThread(id: noneId, title: '', talkNum: 0);
  }

  final int id;
  final String title;
  final int talkNum;

  static const int noneId = -1;

  bool isNotCrerateId() {
    return id == noneId;
  }
}
