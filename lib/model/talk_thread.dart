import 'package:assistant_me/model/llm_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TalkThread {
  const TalkThread._(this.id, this.title, this.system, this.createAt, this._llmModel, this.currentTokens, this.totalUseTokens);

  factory TalkThread.create({
    required int id,
    required String title,
    String? system,
    required DateTime createAt,
    required LlmModel llmModel,
    required int currentTokens,
    required int totalUseTokens,
  }) {
    return TalkThread._(id, title, system, createAt, llmModel, currentTokens, totalUseTokens);
  }

  factory TalkThread.createEmpty(LlmModel selectModel) {
    return TalkThread._(noneId, '', null, DateTime.now(), selectModel, 0, 0);
  }

  static const int noneId = -1;
  static final _dateFormat = DateFormat('yyyy/MM/dd hh:mm');

  final int id;
  final String title;
  final String? system;
  final DateTime createAt;
  final LlmModel _llmModel;
  final int currentTokens;
  final int totalUseTokens;

  bool noneTalk() => id == noneId;
  String toDateTimeString() => _dateFormat.format(createAt);
  LlmModel get model => _llmModel;
  String get modelName => _llmModel.name;
  bool get isTalkModel => _llmModel == LlmModel.gpt3 || _llmModel == LlmModel.gpt4;

  bool get isSettingSystem => (system != null) ? system!.isNotEmpty : false;

  TalkThread updateSystem(String? system) {
    return TalkThread._(
      id,
      title,
      system,
      createAt,
      _llmModel,
      currentTokens,
      totalUseTokens,
    );
  }
}

// 現在の会話の消費トークン
final currentUseTokenStateProvider = StateProvider((_) => 0);
