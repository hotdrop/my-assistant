import 'dart:convert';

import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/talk.dart';

class GptRequest {
  GptRequest._({
    required this.apiKey,
    required this.system,
    required this.newContents,
    required this.histories,
    required this.useModel,
  });

  factory GptRequest.create({
    required String apiKey,
    required String? system,
    required String message,
    required List<Message> histories,
    required LlmModel useModel,
    int? overTokenNum,
  }) {
    if (overTokenNum == null) {
      return GptRequest._(apiKey: apiKey, system: system, newContents: message, histories: histories, useModel: useModel);
    }

    // overTokenNumが指定されている場合はこっちを実行する

    // 細かく会話しているとちょっとずつ履歴会話を切っていってもジリ貧になる。
    // 例えば、GPT3.5を使っていてoverTokenNumが4110だと差分が13になり、最初の会話2つくらい（短いと40程度）をきる
    // この状態だとMAXまでしか回答されないので、途中で切られた回答が送信されてくるのでまた送信して・・・となる。最悪次の回答で高確率でcontext_length_exceededが発生する。
    // そのため、overTokenNumを500くらいあけてしまう。
    int ignoreTokenNum = (overTokenNum + 500) - useModel.maxContext;
    final adjustedHistories = <Message>[];
    for (var history in histories) {
      if (ignoreTokenNum >= 0) {
        ignoreTokenNum = ignoreTokenNum - history.tokenNum;
      } else {
        adjustedHistories.add(history);
      }
    }

    return GptRequest._(apiKey: apiKey, system: system, newContents: message, histories: adjustedHistories, useModel: useModel);
  }

  final String apiKey;
  final String? system;
  final String newContents;
  final List<Message> histories;
  final LlmModel useModel;

  Uri get uri => Uri.parse('https://api.openai.com/v1/chat/completions');

  Map<String, String> get header => {
        'Authorization': 'Bearer $apiKey',
        'Content-type': 'application/json',
      };

  String body() {
    final historyTalks = histories.map((h) => _toJsonContent(h));

    return json.encode({
      'model': useModel.name,
      'messages': [
        if (system != null) {'role': 'system', 'content': system},
        ...historyTalks,
        {'role': 'user', 'content': newContents}
      ]
    });
  }

  Map<String, String> _toJsonContent(Message msg) {
    switch (msg.roleType) {
      case RoleType.user:
        return {'role': 'user', 'content': msg.getValue()};
      case RoleType.assistant:
        return {'role': 'assistant', 'content': msg.getValue()};
      default:
        throw UnimplementedError('未サポートのRoleTypeです index=${msg.roleType.index}');
    }
  }

  // 履歴メッセージの合計トークン数を取得する
  int get currentTotalTokenNum => histories.map((e) => e.tokenNum).fold(0, (prev, e) => prev + e);
}
