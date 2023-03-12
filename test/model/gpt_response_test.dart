import 'dart:convert' as convert;

import 'package:flutter_test/flutter_test.dart';
import 'package:assistant_me/data/remote/entities/gpt_response.dart';

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

  const String test2Response =
      '{"id":"test1","object":"chat.completion","created":1678593375,"model":"gpt-3.5-turbo-0301","usage":{"prompt_tokens":158,"completion_tokens":208,"total_tokens":366},"choices":[{"message":{"role":"assistant","content":"Dartで文字列をDate型に変換するには、`DateTime.parse()`関数を使います。例えば、以下のようになります。\\n\\n```dart\\nString str = \\"2022-01-01 00:00:00\\";\\nDateTime date = DateTime.parse(str);\\n```\\n\\nこの場合、strは`2022-01-01 00:00:00`という形式の文字列です。DateTime.parse()関数を使って、この文字列をDate型に変換しています。変換されたDate型のオブジェクトは、dateに代入されます。\\n\\nなお、文字列の形式によっては、DateTime.parse()関数でエラーとなる場合があります。適切な形式に変換するか、エラー処理を行うようにしてください。"},"finish_reason":null,"index":0}]}';
  test('ChatGPTから実際に受け取ったレスポンスがパースできるか？', () {
    final jsonDecode = convert.jsonDecode(test2Response) as Map<String, Object?>;
    final result = GptResponse.fromJson(jsonDecode);

    expect(result.gptObject, 'chat.completion');
    expect(result.epoch, 1678593375);
    final choices = result.choices;
    expect(choices.length, 1);
  });
}
