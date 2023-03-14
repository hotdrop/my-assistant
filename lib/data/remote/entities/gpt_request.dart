import 'dart:convert';

import 'package:assistant_me/model/talk.dart';

class GptRequest {
  GptRequest({
    required this.apiKey,
    required this.systemRoles,
    required this.newContents,
    required this.histories,
  });

  final String apiKey;
  final List<Map<String, String>>? systemRoles;
  final String newContents;
  final List<Talk> histories;

  Uri get uri => Uri.parse('https://api.openai.com/v1/chat/completions');

  Map<String, String> get header => {
        'Authorization': 'Bearer $apiKey',
        'Content-type': 'application/json',
      };

  // TODO ここでmaxTokenを受け取って過去の会話を削る
  String body() {
    final historyMessages = [];
    for (var history in histories) {
      switch (history.roleType) {
        case RoleType.user:
          historyMessages.add({'role': 'user', 'content': history.message});
          break;
        case RoleType.assistant:
          historyMessages.add({'role': 'assistant', 'content': history.message});
          break;
      }
    }

    return json.encode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        ...systemRoles ?? [],
        ...historyMessages,
        {'role': 'user', 'content': newContents}
      ]
    });
  }
}
