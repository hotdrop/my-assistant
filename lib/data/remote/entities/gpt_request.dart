import 'dart:convert';

import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/talk.dart';

class GptRequest {
  GptRequest({
    required this.apiKey,
    this.system,
    required this.newContents,
    required this.histories,
    required this.useModel,
  });

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

  String body({int? overLimitToken}) {
    final historyTalks = <Map<String, String>>[];

    if (overLimitToken == null) {
      historyTalks.addAll(histories.map((h) => _toJsonContent(h)));
    } else {
      // overLimitTokenが設定されている場合はuseModelのMaxTokenとoverの差し引きで先頭から無視していく
      int ignoreTokenNum = overLimitToken - useModel.maxContext;
      for (var msg in histories) {
        if (ignoreTokenNum >= 0) {
          ignoreTokenNum = ignoreTokenNum - msg.tokenNum;
        } else {
          historyTalks.add(_toJsonContent(msg));
        }
      }
    }

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
}
