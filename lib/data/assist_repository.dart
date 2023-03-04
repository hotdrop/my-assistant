import 'package:assistant_me/data/remote/http_client.dart';
import 'package:assistant_me/model/gpt_request.dart';
import 'package:assistant_me/model/gpt_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final assistRepositoryProvider = Provider((ref) => AssistRepository(ref));

class AssistRepository {
  AssistRepository(this._ref);

  final Ref _ref;

  Future<GptResponse> talk(String message, String apiKey) async {
    final request = GptRequest(
      apiKey: apiKey,
      newContents: message,
    );
    // TODO 検証中なのでAPIは叩かない
    // final response = await _ref.read(httpClientProvider).post(request);

    // TODO ここでローカルストレージに保存する

    return _createDummyResponse();
  }

  GptResponse _createDummyResponse() {
    return GptResponse(
      id: 'chatcmpl-123',
      gptObject: 'chat.completion',
      epoch: 1677652288,
      choices: [
        ChoiceResponse(
          index: 0,
          message: MessageResponse(role: 'assistant', content: 'おはようございます。これはテストです。'),
          finishReason: 'stop',
        )
      ],
      usage: UsageResponse(
        promptTokens: 9,
        completionTokens: 12,
        totalTokens: 21,
      ),
    );
  }
}
