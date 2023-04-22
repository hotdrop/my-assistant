import 'package:assistant_me/model/llm_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TalkThread {
  const TalkThread(this.id, this.title, this.createAt, this._llmModel, this.totalUseTokens);

  factory TalkThread.create({
    required int id,
    required String title,
    required DateTime createAt,
    required LlmModel llmModel,
    required int totalUseTokens,
  }) {
    return TalkThread(id, title, createAt, llmModel, totalUseTokens);
  }

  factory TalkThread.createEmpty(LlmModel selectModel) {
    return TalkThread(noneId, '', DateTime.now(), selectModel, 0);
  }

  static const int noneId = -1;
  static final _dateFormat = DateFormat('yyyy/MM/dd hh:mm');

  final int id;
  final String title;
  final DateTime createAt;
  final LlmModel _llmModel;
  final int totalUseTokens;

  bool noneTalk() => id == noneId;
  String toDateTimeString() => _dateFormat.format(createAt);
  LlmModel get model => _llmModel;
  String get modelName => _llmModel.name;
}

// 現在の会話の消費トークン
final currentUseTokenStateProvider = StateProvider((_) => 0);
