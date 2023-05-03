import 'dart:convert' as convert;
import 'package:assistant_me/data/remote/entities/gpt_error_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String dummyResponse =
      '{"error": {"message": "This model\'s maximum context length is 4097 tokens. However, your messages resulted in 4121 tokens. Please reduce the length of the messages.","type": "invalid_request_error","param": "messages","code": "context_length_exceeded"}}';

  test('エラーレスポンスが正しくパースできるか', () {
    final jsonDecode = convert.jsonDecode(dummyResponse) as Map<String, Object?>;
    final res = GptErrorResponse.fromJson(jsonDecode);

    expect(res.error.code, 'context_length_exceeded');
    expect(res.error.param, 'messages');
    expect(res.error.type, 'invalid_request_error');
    expect(res.error.message,
        'This model\'s maximum context length is 4097 tokens. However, your messages resulted in 4121 tokens. Please reduce the length of the messages.');
  });

  const String dummyResponse2 = '{"error": {"message": "test2","type": "invalid_request_error","param": null,"code": null}}';
  test('一部nullでもエラーレスポンスが正しくパースできるか', () {
    final jsonDecode = convert.jsonDecode(dummyResponse2) as Map<String, Object?>;
    final res = GptErrorResponse.fromJson(jsonDecode);

    expect(res.error.type, 'invalid_request_error');
    expect(res.error.message, 'test2');
  });

  const String dummyResponse3 = '{"error": {"message": "test2","type": "invalid_request_error"}}';
  test('一部かけていてもエラーレスポンスが正しくパースできるか', () {
    final jsonDecode = convert.jsonDecode(dummyResponse3) as Map<String, Object?>;
    final res = GptErrorResponse.fromJson(jsonDecode);

    expect(res.error.type, 'invalid_request_error');
    expect(res.error.message, 'test2');
  });
}
