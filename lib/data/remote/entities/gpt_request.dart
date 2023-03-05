import 'dart:convert';

class GptRequest {
  GptRequest({required this.apiKey, required this.newContents});

  final String apiKey;
  final String newContents;

  Uri get uri => Uri.parse('https://api.openai.com/v1/chat/completions');

  Map<String, String> get header => {
        'authorization': apiKey,
        'Content-type': 'application/json',
      };

  // TODO 引数で前の対話情報を受け取ってjsonに設定する
  String body() {
    return json.encode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'user',
          'content': newContents,
        }
      ],
      'max_tokens': '2000',
    });
  }
}
