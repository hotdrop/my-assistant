import 'package:assistant_me/model/llm_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TalkThread {
  const TalkThread(this.id, this.title, this.createAt, this._llmModel, this._tokenNum, this._countCreateImages, {this.deleteAt});

  factory TalkThread.create({
    required int id,
    required String title,
    required DateTime createAt,
    required LlmModel llmModel,
    required int tokenNum,
    required int countCreateImages,
    DateTime? deleteAt,
  }) {
    return TalkThread(id, title, createAt, llmModel, tokenNum, countCreateImages, deleteAt: deleteAt);
  }

  factory TalkThread.createEmpty(LlmModel selectModel) {
    return TalkThread(noneId, '', DateTime.now(), selectModel, 0, 0);
  }

  static const int noneId = -1;
  static final _dateFormat = DateFormat('yyyy/MM/dd hh:mm');

  final int id;
  final String title;
  final DateTime createAt;
  final DateTime? deleteAt;

  // このスレッドのモデル
  final LlmModel _llmModel;
  // このスレッドで消費した総トークン数
  final int _tokenNum;
  // このスレッドで生成した画像数
  final int _countCreateImages;

  int calcAmount({required int yen}) {
    final tokenAmount = ((_tokenNum / _llmModel.amountPerTokenNum) * (_llmModel.amountDollerPerTokenNum * yen)).round();
    final imageAmount = (_countCreateImages * (_llmModel.amountDollerPerTokenNum * yen)).round();
    return tokenAmount + imageAmount;
  }

  bool noneTalk() => id == noneId;
  String toDateTimeString() => _dateFormat.format(createAt);
  LlmModel get model => _llmModel;
  String get modelName => _llmModel.name;
}

// 現在の会話の消費トークン
final currentUseTokenStateProvider = StateProvider((_) => 0);
