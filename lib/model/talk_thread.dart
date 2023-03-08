import 'package:intl/intl.dart';

class TalkThread {
  const TalkThread({
    required this.id,
    required this.title,
    required this.createAt,
    required this.talkNum,
    required this.totalTalkTokenNum,
    this.deleteAt,
  });

  factory TalkThread.createEmpty() {
    return TalkThread(id: noneId, createAt: DateTime.now(), title: '', talkNum: 0, totalTalkTokenNum: 0);
  }

  final int id;
  final String title;
  final DateTime createAt;
  final DateTime? deleteAt;
  final int talkNum;
  final int totalTalkTokenNum;

  static const int noneId = -1;

  bool isNotCrerateId() {
    return id == noneId;
  }

  static final _dateFormat = DateFormat('yyyy/MM/dd hh:mm');
  String toDateTimeString() => _dateFormat.format(createAt);
}
