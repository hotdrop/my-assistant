import 'dart:convert';

import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/talk.dart';

class GptRequest {
  GptRequest({
    required this.apiKey,
    required this.systemRoles,
    required this.newContents,
    required this.histories,
    required this.maxLimitTokenNum,
    required this.useModel,
  });

  final String apiKey;
  final List<Map<String, String>>? systemRoles;
  final String newContents;
  final List<Message> histories;
  final int maxLimitTokenNum;
  final LlmModel useModel;

  Uri get uri => Uri.parse('https://api.openai.com/v1/chat/completions');

  Map<String, String> get header => {
        'Authorization': 'Bearer $apiKey',
        'Content-type': 'application/json',
      };

  String body() {
    final historyTalks = histories.map((h) {
      switch (h.roleType) {
        case RoleType.user:
          return {'role': 'user', 'content': h.getValue()};
        case RoleType.assistant:
          return {'role': 'assistant', 'content': h.getValue()};
        default:
          throw UnimplementedError('未サポートのRoleTypeです index=${h.roleType.index}');
      }
    }).toList();

    return json.encode({
      'model': useModel.name,
      'messages': [
        ...systemRoles ?? [],
        ...historyTalks,
        {'role': 'user', 'content': newContents}
      ]
    });
  }
}

