import 'dart:convert';

class GptImageRequest {
  GptImageRequest({
    required this.apiKey,
    required this.newContents,
    required this.num,
  });

  final String apiKey;
  final String newContents;
  final int num;

  Uri get uri => Uri.parse('https://api.openai.com/v1/images/generations');

  Map<String, String> get header => {
        'Authorization': 'Bearer $apiKey',
        'Content-type': 'application/json',
      };

  String body() {
    return json.encode(
      {
        'prompt': newContents,
        'n': num,
        'size': '512x512',
      },
    );
  }
}
