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
    int ignoreTokenNum = overTokenNum - useModel.maxContext;
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
