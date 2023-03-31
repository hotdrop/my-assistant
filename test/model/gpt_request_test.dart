import 'package:assistant_me/data/remote/entities/gpt_request.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String expectFirstTalkBody = '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"こんにちわ"}]}';
  test('履歴がない状態のリクエストで生成したjsonが意図した形式になっているか', () {
    final container = ProviderContainer();
    final request = GptRequest(
      apiKey: 'test',
      systemRoles: container.read(appSettingsProvider).systemMessages,
      maxLimitTokenNum: container.read(appSettingsProvider).maxTokensNum,
      newContents: 'こんにちわ',
      histories: [],
      useModel: container.read(appSettingsProvider).llmModel,
    );
    expect(request.body(), expectFirstTalkBody);
  });

  const String expectSecondTalkBody =
      '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"これはテストですか？"},{"role":"assistant","content":"はい、履歴のやり取りが1回のテストです。"},{"role":"user","content":"ありがとうございます。"}]}';
  test('履歴が1回のやり取りの状態のリクエストで生成したjsonが意図した形式になっているか', () {
    final container = ProviderContainer();
    final request = GptRequest(
      apiKey: 'test',
      systemRoles: container.read(appSettingsProvider).systemMessages,
      maxLimitTokenNum: container.read(appSettingsProvider).maxTokensNum,
      newContents: 'ありがとうございます。',
      histories: [
        const Talk(roleType: RoleType.user, message: 'これはテストですか？', tokenNum: 0),
        const Talk(roleType: RoleType.assistant, message: 'はい、履歴のやり取りが1回のテストです。', tokenNum: 0),
      ],
      useModel: container.read(appSettingsProvider).llmModel,
    );
    expect(request.body(), expectSecondTalkBody);
  });

  const String expectThirdTalkBody =
      '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"これはテストですか？"},{"role":"assistant","content":"はい、履歴のやり取りが1回のテストです。"},{"role":"user","content":"ありがとうございます。2回目のやりとりをしましょう"},{"role":"assistant","content":"はい、2回目のやり取りをしました。"},{"role":"user","content":"ありがとうございました!"}]}';
  test('履歴が2回1のやり取りの状態のリクエストで生成したjsonが意図した形式になっているか', () {
    final container = ProviderContainer();
    final request = GptRequest(
      apiKey: 'test',
      systemRoles: container.read(appSettingsProvider).systemMessages,
      maxLimitTokenNum: container.read(appSettingsProvider).maxTokensNum,
      newContents: 'ありがとうございました!',
      histories: [
        const Talk(roleType: RoleType.user, message: 'これはテストですか？', tokenNum: 0),
        const Talk(roleType: RoleType.assistant, message: 'はい、履歴のやり取りが1回のテストです。', tokenNum: 0),
        const Talk(roleType: RoleType.user, message: 'ありがとうございます。2回目のやりとりをしましょう', tokenNum: 0),
        const Talk(roleType: RoleType.assistant, message: 'はい、2回目のやり取りをしました。', tokenNum: 0),
      ],
      useModel: container.read(appSettingsProvider).llmModel,
    );
    expect(request.body(), expectThirdTalkBody);
  });
}
