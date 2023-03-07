import 'package:assistant_me/data/remote/entities/gpt_request.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String expectFirstTalkBody =
      '{"model":"gpt-3.5-turbo","messages":[{"role":"system","content":"あなたはIT業界で仕事をしているエンジニアのアシスタントです。"},{"role":"system","content":"あなたはモバイルアプリ開発のエキスパートです。"},{"role":"user","content":"こんにちわ"}]}';
  test('履歴がない状態のリクエストで生成したjsonが意図した形式になっているか', () {
    final request = GptRequest(
      apiKey: 'test',
      newContents: 'こんにちわ',
      histories: [],
    );
    expect(request.body(), expectFirstTalkBody);
  });

  const String expectSecondTalkBody =
      '{"model":"gpt-3.5-turbo","messages":[{"role":"system","content":"あなたはIT業界で仕事をしているエンジニアのアシスタントです。"},{"role":"system","content":"あなたはモバイルアプリ開発のエキスパートです。"},{"role":"user","content":"これはテストですか？"},{"role":"assistant","content":"はい、履歴のやり取りが1回のテストです。"},{"role":"user","content":"ありがとうございます。"}]}';
  test('履歴が1回のやり取りの状態のリクエストで生成したjsonが意図した形式になっているか', () {
    final request = GptRequest(
      apiKey: 'test',
      newContents: 'ありがとうございます。',
      histories: [
        Talk(dateTime: DateTime.now(), roleType: RoleType.user, message: 'これはテストですか？', totalTokenNum: 0),
        Talk(dateTime: DateTime.now(), roleType: RoleType.assistant, message: 'はい、履歴のやり取りが1回のテストです。', totalTokenNum: 0),
      ],
    );
    expect(request.body(), expectSecondTalkBody);
  });

  const String expectThirdTalkBody =
      '{"model":"gpt-3.5-turbo","messages":[{"role":"system","content":"あなたはIT業界で仕事をしているエンジニアのアシスタントです。"},{"role":"system","content":"あなたはモバイルアプリ開発のエキスパートです。"},{"role":"user","content":"これはテストですか？"},{"role":"assistant","content":"はい、履歴のやり取りが1回のテストです。"},{"role":"user","content":"ありがとうございます。2回目のやりとりをしましょう"},{"role":"assistant","content":"はい、2回目のやり取りをしました。"},{"role":"user","content":"ありがとうございました!"}]}';
  test('履歴が2回1のやり取りの状態のリクエストで生成したjsonが意図した形式になっているか', () {
    final request = GptRequest(
      apiKey: 'test',
      newContents: 'ありがとうございました!',
      histories: [
        Talk(dateTime: DateTime.now(), roleType: RoleType.user, message: 'これはテストですか？', totalTokenNum: 0),
        Talk(dateTime: DateTime.now(), roleType: RoleType.assistant, message: 'はい、履歴のやり取りが1回のテストです。', totalTokenNum: 0),
        Talk(dateTime: DateTime.now(), roleType: RoleType.user, message: 'ありがとうございます。2回目のやりとりをしましょう', totalTokenNum: 0),
        Talk(dateTime: DateTime.now(), roleType: RoleType.assistant, message: 'はい、2回目のやり取りをしました。', totalTokenNum: 0),
      ],
    );
    expect(request.body(), expectThirdTalkBody);
  });
}
