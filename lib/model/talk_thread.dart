class TalkThread {
  const TalkThread({required this.id, required this.title, required this.talkNum, required this.totalTalkTokenNum, this.deleteAt});

  factory TalkThread.createEmpty() {
    return const TalkThread(id: noneId, title: '', talkNum: 0, totalTalkTokenNum: 0);
  }

  final int id;
  final String title;
  final DateTime? deleteAt;
  final int talkNum;
  final int totalTalkTokenNum;

  static const int noneId = -1;

  bool isNotCrerateId() {
    return id == noneId;
  }
}
