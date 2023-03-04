import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant_me/model/gpt_request.dart';
import 'package:assistant_me/model/gpt_response.dart';

final httpClientProvider = Provider((_) => _HttpClient());

class _HttpClient {
  Future<GptResponse> post(GptRequest request) async {
    final response = await http.post(request.uri, headers: request.header, body: request.body());
    if (response.statusCode >= 400) {
      throw Exception(['APIでエラーが発生しました。 ステータスコード: ${response.statusCode} エラーメッセージ: ${response.body}']);
    }

    if (response.body.isEmpty) {
      throw Exception(['APIでエラーが発生しました。 ステータスコード: ${response.statusCode} bodyは空です。']);
    }
    // jsonDecodeはMap<String, Object?>かList<Map<String, Object?>>になる
    final jsonDecode = convert.jsonDecode(response.body) as Map<String, Object?>;
    return GptResponse.fromJson(jsonDecode);
  }
}
