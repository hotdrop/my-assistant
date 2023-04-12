import 'package:assistant_me/data/remote/entities/gpt_image_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_image_response.dart';
import 'package:assistant_me/model/app_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant_me/data/remote/entities/gpt_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_response.dart';

final httpClientProvider = Provider((_) => _HttpClient());

class _HttpClient {
  ///
  /// Create chat completion APIを実行する
  ///
  Future<GptResponse> post(GptRequest request) async {
    final response = await http.post(request.uri, headers: request.header, body: request.body());
    if (response.statusCode >= 400) {
      throw AppException(message: 'APIでエラーが発生しました。 ステータスコード: ${response.statusCode} エラーメッセージ: ${response.body}');
    }

    if (response.body.isEmpty) {
      throw AppException(message: 'APIでエラーが発生しました。 ステータスコード: ${response.statusCode} bodyは空です。');
    }

    // レスポンスのマルチバイトが文字化けするのでデコード
    final responseBody = convert.utf8.decode(response.bodyBytes);
    final jsonDecode = convert.jsonDecode(responseBody) as Map<String, Object?>;
    return GptResponse.fromJson(jsonDecode);
  }

  ///
  /// Create Image APIを実行する
  ///
  Future<GptImageResponse> postToCreateImage(GptImageRequest request) async {
    final response = await http.post(request.uri, headers: request.header, body: request.body());
    if (response.statusCode >= 400) {
      throw AppException(message: 'APIでエラーが発生しました。 ステータスコード: ${response.statusCode} エラーメッセージ: ${response.body}');
    }

    if (response.body.isEmpty) {
      throw AppException(message: 'APIでエラーが発生しました。 ステータスコード: ${response.statusCode} bodyは空です。');
    }

    // レスポンスのマルチバイトが文字化けするのでデコード
    final responseBody = convert.utf8.decode(response.bodyBytes);
    final jsonDecode = convert.jsonDecode(responseBody) as Map<String, Object?>;
    return GptImageResponse.fromJson(jsonDecode);
  }
}
