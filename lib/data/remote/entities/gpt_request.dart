import 'dart:convert';

import 'package:assistant_me/model/talk.dart';

class GptRequest {
  GptRequest({
    required this.apiKey,
    required this.systemRoles,
    required this.newContents,
    required this.histories,
    required this.maxLimitTokenNum,
  });

  final String apiKey;
  final List<Map<String, String>>? systemRoles;
  final String newContents;
  final List<Talk> histories;
  final int maxLimitTokenNum;

  Uri get uri => Uri.parse('https://api.openai.com/v1/chat/completions');

  Map<String, String> get header => {
        'Authorization': 'Bearer $apiKey',
        'Content-type': 'application/json',
      };

  ///
  /// ここでcontextが最大値を超えた場合にcontext_legnth_exceededエラーで会話が止まらないように過去の会話を履歴に含めないようにしている。
  /// ただ、この実装は根本的な解決をしておらず一旦応急処置としている。そのため以下のような穴がある。
  /// ・これから送信する会話のcontext数がわかっていないので余裕を持って過去の会話を削除する。そのため削除不要な会話まで削除してしまう可能性がある。
  /// ・それでも一気にcontextを消費するような回答だったら会話継続ができなくなる。
  ///
  String body() {
    final historyTalks = [];
    var totalTokens = 0;

    final reversedHistories = histories.reversed;
    for (var history in reversedHistories) {
      if (totalTokens + history.tokenNum > maxLimitTokenNum) {
        break;
      }

      switch (history.roleType) {
        case RoleType.user:
          historyTalks.add({'role': 'user', 'content': history.message});
          break;
        case RoleType.assistant:
          historyTalks.add({'role': 'assistant', 'content': history.message});
          break;
      }
      totalTokens += history.tokenNum;
    }

    return json.encode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        ...systemRoles ?? [],
        ...historyTalks.reversed,
        {'role': 'user', 'content': newContents}
      ]
    });
  }
}
