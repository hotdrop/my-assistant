import 'package:assistant_me/common/logger.dart';
import 'package:assistant_me/data/local/dao/talk_dao.dart';
import 'package:assistant_me/data/remote/entities/gpt_request.dart';
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
    return await _ref.read(talkDaoProvider).createThread(message);
  }

  Future<TalkThread> findThread(int id) async {
    return await _ref.read(talkDaoProvider).findThread(id);
  }

  Future<Talk> talk(String message, String apiKey, TalkThread thread) async {
    final historyTalks = await _ref.read(talkDaoProvider).findTalks(thread.id);
    final request = GptRequest(
      apiKey: apiKey,
      systemRoles: _ref.read(appSettingsProvider).systemMessages,
      maxLimitTokenNum: _ref.read(appSettingsProvider).maxTokensNum,
      newContents: message,
      histories: historyTalks,
      useModel: _ref.read(appSettingsProvider).llmModel,
    );

    AppLogger.d('[送信するリクエスト情報]\n header: ${request.header} \n body: ${request.body()}');
    final response = await _ref.read(httpClientProvider).post(request);

    final messageObj = response.choices.first.message;

    // ここ紛らわしいので注意！
    // Threadには消費トークン数を保持する
    // Talkには個々のTalkが使用したトークン数を保持する（APIからは合計トークンが返ってくるので差し引いて保存する）
    final currentTotalTokenNum = historyTalks.map((e) => e.tokenNum).fold(0, (prev, e) => prev + e);
    final talk = Talk.create(
      roleType: Talk.toRoleType(messageObj.role),
      message: messageObj.content,
      tokenNum: response.usage.totalTokens - currentTotalTokenNum,
    );

    await _ref.read(talkDaoProvider).save(
          threadId: thread.id,
          message: message,
          talk: talk,
          currentTotalTokens: response.usage.totalTokens,
        );

    return talk;
  }
}
