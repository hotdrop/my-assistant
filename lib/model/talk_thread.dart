class TalkThread {
  const TalkThread({required this.id, required this.title, required this.talkNum, required this.totalTokenNum});

  factory TalkThread.createEmpty() {
    return const TalkThread(id: noneId, title: '', talkNum: 0, totalTokenNum: 0);
  }

  final int id;
  final String title;
  final int talkNum;
  final int totalTokenNum;

  static const int noneId = -1;

  bool isNotCrerateId() {
    return id == noneId;
  }
}
