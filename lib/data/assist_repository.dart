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
    final newThread = await _ref.read(talkDaoProvider).createThread(message);
    return newThread;
  }

  Future<Talk> talk(String message, String apiKey, TalkThread thread) async {
    final historyTalks = await _ref.read(talkDaoProvider).findTalks(thread.id);
    // TODO ここで履歴をセットする際、maxTokenを計算して最初の方の会話を除外する
    final request = GptRequest(
      apiKey: apiKey,
      systemRoles: _ref.read(appSettingsProvider).systemMessages,
      newContents: message,
      histories: historyTalks,
    );

    AppLogger.d('[送信するリクエスト情報]\n header: ${request.header} \n body: ${request.body()}');
    final response = await _ref.read(httpClientProvider).post(request);

    final messageObj = response.choices.first.message;
    final talk = Talk.create(
      roleType: Talk.toRoleType(messageObj.role),
      message: messageObj.content,
      totalTokenNum: response.usage.totalTokens,
    );

    await _ref.read(talkDaoProvider).save(threadId: thread.id, message: message, talk: talk);

    return talk;
  }
}
