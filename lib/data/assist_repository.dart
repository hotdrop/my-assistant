import 'package:assistant_me/data/local/dao/talk_dao.dart';
import 'package:assistant_me/data/remote/entities/gpt_image_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_response.dart';
import 'package:assistant_me/data/remote/http_client.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assistRepositoryProvider = Provider((ref) => AssistRepository(ref));

class AssistRepository {
  AssistRepository(this._ref);

  final Ref _ref;

  ///
  /// 会話の初回でのみ実行する
  ///
  Future<TalkThread> createThread(String message) async {
    final useModel = _ref.read(appSettingsProvider).useLlmModel;
    return await _ref.read(talkDaoProvider).createThread(message, useModel);
  }

  Future<TalkThread> findThread(int id) async {
    return await _ref.read(talkDaoProvider).findThread(id);
  }

  Future<Message> messageTalk({required String apiKey, required TalkThread thread, required String message}) async {
    final historyTalks = await _ref.read(talkDaoProvider).findMessageTalks(thread.id);
    final request = GptRequest(
      apiKey: apiKey,
      systemRoles: _ref.read(appSettingsProvider).systemMessages,
      maxLimitTokenNum: _ref.read(appSettingsProvider).maxTokensNum,
      newContents: message,
      histories: historyTalks,
      useModel: _ref.read(appSettingsProvider).useLlmModel,
    );

    final response = _createDummyResponse(); //await _ref.read(httpClientProvider).post(request);

    // 【注意！】Threadには消費トークン数を保持する
    // Talkには個々のTalkが使用したトークン数を保持する（APIからは合計トークンが返ってくるので差し引いて保存する）
    final currentTotalTokenNum = historyTalks.map((e) => e.tokenNum).fold(0, (prev, e) => prev + e);
    final talk = Message.create(
      roleType: Talk.toRoleType(response.choices.first.message.role),
      value: response.choices.first.message.content,
      tokenNum: response.usage.totalTokens - currentTotalTokenNum,
    );

    await _ref.read(talkDaoProvider).save(
          threadId: thread.id,
          message: message,
          talk: talk,
          currentTotalTokens: response.usage.totalTokens,
        );

    // 現在のトークンを更新する
    _ref.read(currentUseTokenStateProvider.notifier).state = response.usage.totalTokens;

    return talk;
  }

  Future<ImageTalk> imageTalk({required String apiKey, required TalkThread thread, required String message, required int createNum}) async {
    final request = GptImageRequest(
      apiKey: apiKey,
      newContents: message,
      num: createNum,
    );

    final response = await _ref.read(httpClientProvider).postToCreateImage(request);
    final imageTalk = ImageTalk.create(
      urls: response.urls.map((r) => r.url).toList(),
    );

    await _ref.read(talkDaoProvider).saveImageTalk(
          threadId: thread.id,
          message: message,
          iamgeUrls: imageTalk.getValue(),
        );

    return imageTalk;
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
        promptTokens: 100,
        completionTokens: 3900,
        totalTokens: 4000,
      ),
    );
  }
}
