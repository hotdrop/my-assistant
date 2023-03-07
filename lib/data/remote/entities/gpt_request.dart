import 'dart:convert';

import 'package:assistant_me/model/talk.dart';

class GptRequest {
  GptRequest({
    required this.apiKey,
    required this.newContents,
    required this.histories,
  });

  final String apiKey;
  final String newContents;
  final List<Talk> histories;

  Uri get uri => Uri.parse('https://api.openai.com/v1/chat/completions');

  Map<String, String> get header => {
        'authorization': apiKey,
        'Content-type': 'application/json',
      };

  List<Map<String, String>> get systemMessages => [
        {'role': 'system', 'content': 'あなたはIT業界で仕事をしているエンジニアのアシスタントです。'},
        {'role': 'system', 'content': 'あなたはモバイルアプリ開発のエキスパートです。'},
      ];

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
        ...systemMessages,
        ...historyMessages,
        {'role': 'user', 'content': newContents}
      ]
    });
  }
}
