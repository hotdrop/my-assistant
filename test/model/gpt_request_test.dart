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
      maxLimitTokenNum: container.read(appSettingsProvider).maxTokensNum,
      newContents: 'こんにちわ',
      histories: [],
      useModel: container.read(appSettingsProvider).useLlmModel,
    );
    expect(request.body(), expectFirstTalkBody);
  });

  const String expectSecondTalkBody =
      '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"これはテストですか？"},{"role":"assistant","content":"はい、履歴のやり取りが1回のテストです。"},{"role":"user","content":"ありがとうございます。"}]}';
  test('Systemが設定された状態のリクエストで生成したjsonが意図した形式になっているか', () {
    final container = ProviderContainer();
    final request = GptRequest(
      apiKey: 'test',
      maxLimitTokenNum: container.read(appSettingsProvider).maxTokensNum,
      newContents: 'ありがとうございます。',
      histories: [
        Message.create(roleType: RoleType.user, value: 'これはテストですか？', tokenNum: 0),
        Message.create(roleType: RoleType.assistant, value: 'はい、履歴のやり取りが1回のテストです。', tokenNum: 0),
      ],
      useModel: container.read(appSettingsProvider).useLlmModel,
    );
    expect(request.body(), expectSecondTalkBody);
  });

  const String expectThirdTalkBody =
      '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"これはテストですか？"},{"role":"assistant","content":"はい、履歴のやり取りが1回のテストです。"},{"role":"user","content":"ありがとうございます。2回目のやりとりをしましょう"},{"role":"assistant","content":"はい、2回目のやり取りをしました。"},{"role":"user","content":"ありがとうございました!"}]}';
  test('履歴が2回1のやり取りの状態のリクエストで生成したjsonが意図した形式になっているか', () {
    final container = ProviderContainer();
    final request = GptRequest(
      apiKey: 'test',
      maxLimitTokenNum: container.read(appSettingsProvider).maxTokensNum,
      newContents: 'ありがとうございました!',
      histories: [
        Message.create(roleType: RoleType.user, value: 'これはテストですか？', tokenNum: 0),
        Message.create(roleType: RoleType.assistant, value: 'はい、履歴のやり取りが1回のテストです。', tokenNum: 0),
        Message.create(roleType: RoleType.user, value: 'ありがとうございます。2回目のやりとりをしましょう', tokenNum: 0),
        Message.create(roleType: RoleType.assistant, value: 'はい、2回目のやり取りをしました。', tokenNum: 0),
      ],
      useModel: container.read(appSettingsProvider).useLlmModel,
    );
    expect(request.body(), expectThirdTalkBody);
  });

  const String expectWithSystemTalkBody =
      '{"model":"gpt-3.5-turbo","messages":[{"role":"system","content":"これはシステムロールです。"},{"role":"user","content":"こんにちわ"}]}';
  test('システムロールを設定した状態のリクエストで生成したjsonが意図した形式になっているか', () {
    final container = ProviderContainer();
    final request = GptRequest(
      apiKey: 'test',
      system: 'これはシステムロールです。',
      maxLimitTokenNum: container.read(appSettingsProvider).maxTokensNum,
      newContents: 'こんにちわ',
      histories: [],
      useModel: container.read(appSettingsProvider).useLlmModel,
    );
    expect(request.body(), expectWithSystemTalkBody);
  });
}
