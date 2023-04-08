import 'package:assistant_me/model/llm_model.dart';
import 'package:intl/intl.dart';

class TalkThread {
  const TalkThread({
    required this.id,
    required this.title,
    required this.createAt,
    required this.llmModel,
    required this.talkNum,
    required this.totalTalkTokenNum,
    required this.currentTalkNum,
    this.deleteAt,
  });

  factory TalkThread.createEmpty(LlmModel selectModel) {
    return TalkThread(
      id: noneId,
      title: '',
      createAt: DateTime.now(),
      llmModel: selectModel,
      talkNum: 0,
      totalTalkTokenNum: 0,
      currentTalkNum: 0,
    );
  }

  final int id;
  final String title;
  final DateTime createAt;
  final DateTime? deleteAt;
  // このスレッドのモデル
  final LlmModel llmModel;
  // このスレッドで行った会話の数
  final int talkNum;
  // このスレッドで消費した総トークン数
  final int totalTalkTokenNum;
  // このスレッドの利用トークン数
  final int currentTalkNum;

  static const int noneId = -1;

  bool isNotCrerateId() {
    return id == noneId;
  }

  static final _dateFormat = DateFormat('yyyy/MM/dd hh:mm');
  String toDateTimeString() => _dateFormat.format(createAt);
}
