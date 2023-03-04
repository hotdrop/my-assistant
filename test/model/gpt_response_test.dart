import 'package:assistant_me/model/gpt_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert' as convert;

void main() {
  const String dummyResponse =
      '{"id": "chatcmpl-123","object": "chat.completion","created": 1677652288,"choices": [{"index": 0,"message": {"role": "assistant","content": "\\n\\nHello there, how may I assist you today?"},"finish_reason": "stop"}],"usage": {"prompt_tokens": 9,"completion_tokens": 12,"total_tokens": 21}}';

  test('レスポンスが正しくパースできるか', () {
    final jsonDecode = convert.jsonDecode(dummyResponse) as Map<String, Object?>;
    final result = GptResponse.fromJson(jsonDecode);

    expect(result.id, 'chatcmpl-123');
    expect(result.gptObject, 'chat.completion');
    expect(result.epoch, 1677652288);
    final choices = result.choices;
    expect(choices.length, 1);

    final firstChoice = choices.first;
    expect(firstChoice.index, 0);
    expect(firstChoice.finishReason, 'stop');

    final message = firstChoice.message;
    expect(message.role, 'assistant');
    expect(message.content, '\n\nHello there, how may I assist you today?');

    final usage = result.usage;
    expect(usage.promptTokens, 9);
    expect(usage.completionTokens, 12);
    expect(usage.totalTokens, 21);
  });
}
