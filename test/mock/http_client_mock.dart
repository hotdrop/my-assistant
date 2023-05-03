import 'package:assistant_me/data/remote/entities/gpt_error_response.dart';
import 'package:assistant_me/data/remote/entities/gpt_response.dart';
import 'package:assistant_me/data/remote/entities/gpt_result_response.dart';
import 'package:assistant_me/data/remote/entities/gpt_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_image_response.dart';
import 'package:assistant_me/data/remote/entities/gpt_image_request.dart';
import 'package:assistant_me/data/remote/http_client.dart';

class HttpClientMock implements HttpClient {
  @override
  Future<GptResultResponse> post(GptRequest request) async {
    if (request.apiKey == '成功テスト') {
      final res = _createSuccess();
      return Future.value(GptResultResponse.success(res));
    }

    if (request.apiKey == '失敗テスト') {
      final res = _createError();
      return Future.value(GptResultResponse.error(res));
    }

    if (request.apiKey == 'リトライ成功テスト') {
      final totalToken = request.currentTotalTokenNum;
      if (totalToken >= 5000) {
        final res = _createOverTokenError();
        return Future.value(GptResultResponse.error(res));
      } else {
        final res = _createSuccess();
        return Future.value(GptResultResponse.success(res));
      }
    }

    if (request.apiKey == 'リトライ失敗テスト') {
      final totalToken = request.currentTotalTokenNum;
      if (totalToken >= 5000) {
        final res = _createOverTokenError();
        return Future.value(GptResultResponse.error(res));
      } else {
        final res = _createError();
        return Future.value(GptResultResponse.error(res));
      }
    }

    if (request.apiKey == 'トークン超超過テスト') {
      final res = _createBigOverTokenError();
      return Future.value(GptResultResponse.error(res));
    }

    throw UnimplementedError();
  }

  GptResponse _createSuccess() {
    return GptResponse(
      id: 'test1',
      gptObject: '',
      epoch: 12345,
      choices: [
        ChoiceResponse(index: 1, message: MessageResponse(role: 'assistant', content: '成功です')),
      ],
      usage: UsageResponse(promptTokens: 10, completionTokens: 20, totalTokens: 30),
    );
  }

  GptErrorResponse _createError() {
    return GptErrorResponse(
      error: GptErrorDetailResponse(
        code: 'test_error',
        message: 'エラーですよ',
        type: 'test-error-type',
        param: 'messages',
      ),
    );
  }

  GptErrorResponse _createOverTokenError() {
    return GptErrorResponse(
      error: GptErrorDetailResponse(
        code: 'context_length_exceeded',
        message:
            'This model\'s maximum context length is 4097 tokens. However, your messages resulted in 5100 tokens.Please reduce the length of the messages.',
        type: 'test-error-type',
        param: 'messages',
      ),
    );
  }

  GptErrorResponse _createBigOverTokenError() {
    return GptErrorResponse(
      error: GptErrorDetailResponse(
        code: 'context_length_exceeded',
        message:
            'This model\'s maximum context length is 4097 tokens. However, your messages resulted in 99999 tokens.Please reduce the length of the messages.',
        type: 'test-error-type',
        param: 'messages',
      ),
    );
  }

  @override
  Future<GptImageResponse> postToCreateImage(GptImageRequest request) {
    throw UnimplementedError();
  }
}
