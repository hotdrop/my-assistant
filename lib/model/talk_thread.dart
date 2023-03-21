import 'package:intl/intl.dart';

class TalkThread {
  const TalkThread({
    required this.id,
    required this.title,
    required this.createAt,
    required this.talkNum,
    required this.totalTalkTokenNum,
    required this.currentTalkNum,
    this.deleteAt,
  });

  factory TalkThread.createEmpty() {
    return TalkThread(id: noneId, createAt: DateTime.now(), title: '', talkNum: 0, totalTalkTokenNum: 0, currentTalkNum: 0);
  }

  final int id;
  final String title;
  final DateTime createAt;
  final DateTime? deleteAt;
  // このスレッドで行った会話の数
  final int talkNum;
  // このスレッドで消費した総トークン数
  final int totalTalkTokenNum;
  // このスレッドの利用トークン数。このトークン数はGPT3.5 turboモデルでMAX4096
  final int currentTalkNum;

  static const int noneId = -1;

  bool isNotCrerateId() {
    return id == noneId;
  }

  static final _dateFormat = DateFormat('yyyy/MM/dd hh:mm');
  String toDateTimeString() => _dateFormat.format(createAt);
}
