import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assistant_me/data/remote/entities/gpt_error_response.dart';
import 'package:assistant_me/data/remote/entities/gpt_image_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_image_response.dart';
import 'package:assistant_me/data/remote/entities/gpt_result_response.dart';
import 'package:assistant_me/data/remote/entities/gpt_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_response.dart';
import 'package:assistant_me/model/app_exception.dart';

final httpClientProvider = Provider((_) => HttpClient());

class HttpClient {
  ///
  /// Create chat completion APIを実行する
  ///
  Future<GptResultResponse> post(GptRequest request) async {
    final response = await http.post(request.uri, headers: request.header, body: request.body());

    if (response.statusCode >= 400) {
      final jd = convert.jsonDecode(response.body) as Map<String, Object?>;
      final errorResponse = GptErrorResponse.fromJson(jd);

      return GptResultResponse.error(errorResponse);
    }

    // レスポンスのマルチバイトが文字化けするのでデコード
    final responseBody = convert.utf8.decode(response.bodyBytes);
    final jsonDecode = convert.jsonDecode(responseBody) as Map<String, Object?>;
    final gptResponse = GptResponse.fromJson(jsonDecode);

    return GptResultResponse.success(gptResponse);
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
