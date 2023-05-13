import 'package:assistant_me/data/assist_repository.dart';
import 'package:assistant_me/data/local/dao/talk_dao.dart';
import 'package:assistant_me/data/remote/http_client.dart';
import 'package:assistant_me/model/app_exception.dart';
import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/http_client_mock.dart';
import 'mock/talk_dao_mock.dart';

void main() {
  test('メッセージ取得のレスポンスが正常だった場合に意図した動作になるか', () async {
    final container = ProviderContainer(overrides: [
      talkDaoProvider.overrideWithValue(TalkDaoMock()),
      httpClientProvider.overrideWithValue(HttpClientMock()),
    ]);
    final repository = container.read(assistRepositoryProvider);
    final thread = TalkThread.create(
      id: 1,
      title: 'test1',
      createAt: DateTime.now(),
      llmModel: LlmModel.gpt3,
      currentTokens: 0,
      totalUseTokens: 0,
    );

    final talk = await repository.messageTalk(
      apiKey: '成功テスト',
      thread: thread,
      message: 'success',
    );
    expect(talk.getValue(), '成功です');
  });

  test('メッセージ取得でトークン超過以外のエラーになった場合は例外が返されるか', () async {
    final container = ProviderContainer(overrides: [
      talkDaoProvider.overrideWithValue(TalkDaoMock()),
      httpClientProvider.overrideWithValue(HttpClientMock()),
    ]);
    final repository = container.read(assistRepositoryProvider);
    final thread = TalkThread.create(
      id: 2,
      title: 'test2',
      createAt: DateTime.now(),
      llmModel: LlmModel.gpt3,
      currentTokens: 0,
      totalUseTokens: 0,
    );

    expect(
        () async => await repository.messageTalk(
              apiKey: '失敗テスト',
              thread: thread,
              message: 'failure',
            ),
        throwsA(isA<AppException>()));
  });

  test('メッセージ取得でトークン超過エラーになった場合はリトライされるか（リトライ成功パターン）', () async {
    final container = ProviderContainer(overrides: [
      talkDaoProvider.overrideWithValue(TalkDaoMock()),
      httpClientProvider.overrideWithValue(HttpClientMock()),
    ]);
    final repository = container.read(assistRepositoryProvider);
    final thread = TalkThread.create(
      id: 3,
      title: 'test3',
      createAt: DateTime.now(),
      llmModel: LlmModel.gpt3,
      currentTokens: 0,
      totalUseTokens: 0,
    );

    final talk = await repository.messageTalk(
      apiKey: 'リトライ成功テスト',
      thread: thread,
      message: 'success',
    );
    expect(talk.getValue(), '成功です');
  });

  test('メッセージ取得でトークン超過エラーになった場合はリトライされるか（リトライ失敗パターン）', () async {
    final container = ProviderContainer(overrides: [
      talkDaoProvider.overrideWithValue(TalkDaoMock()),
      httpClientProvider.overrideWithValue(HttpClientMock()),
    ]);
    final repository = container.read(assistRepositoryProvider);
    final thread = TalkThread.create(
      id: 4,
      title: 'test4',
      createAt: DateTime.now(),
      llmModel: LlmModel.gpt3,
      currentTokens: 0,
      totalUseTokens: 0,
    );

    expect(
        () async => await repository.messageTalk(
              apiKey: 'リトライ失敗テスト',
              thread: thread,
              message: 'failure',
            ),
        throwsA(isA<AppException>()));
  });

  test('メッセージ取得で巨大なトークン超過エラーになった場合はエラーになるか', () async {
    final container = ProviderContainer(overrides: [
      talkDaoProvider.overrideWithValue(TalkDaoMock()),
      httpClientProvider.overrideWithValue(HttpClientMock()),
    ]);
    final repository = container.read(assistRepositoryProvider);
    final thread = TalkThread.create(
      id: 5,
      title: 'test5',
      createAt: DateTime.now(),
      llmModel: LlmModel.gpt3,
      currentTokens: 0,
      totalUseTokens: 0,
    );

    expect(
        () async => await repository.messageTalk(
              apiKey: 'トークン超超過テスト',
              thread: thread,
              message: 'failure',
            ),
        throwsA(isA<AppException>()));
  });
}
