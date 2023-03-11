import 'package:assistant_me/common/logger.dart';
import 'package:assistant_me/data/local/dao/talk_dao.dart';
import 'package:assistant_me/data/remote/entities/gpt_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_response.dart';
import 'package:assistant_me/data/remote/http_client.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

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
    final request = GptRequest(
      apiKey: apiKey,
      newContents: message,
      histories: historyTalks,
    );
    AppLogger.d('[送信するリクエスト情報]\n header: ${request.header} \n body: ${request.body()}');

    // TODO 検証中なのでAPIは叩かない
    // final response = await _ref.read(httpClientProvider).post(request);
    await Future<void>.delayed(const Duration(seconds: 2));
    final response = _createDummyResponse();

    final messageObj = response.choices.first.message;
    final talk = Talk.create(
      roleType: Talk.toRoleType(messageObj.role),
      message: messageObj.content,
      totalTokenNum: response.usage.totalTokens,
    );

    await _ref.read(talkDaoProvider).save(threadId: thread.id, message: message, talk: talk);

    return talk;
  }

  GptResponse _createDummyResponse() {
    return GptResponse(
      id: 'chatcmpl-123',
      gptObject: 'chat.completion',
      epoch: 1677652288,
      choices: [
        ChoiceResponse(
          index: 0,
          message: MessageResponse(
              role: 'assistant',
              content:
                  'おはようございます。これはテストです。\n\n1. 白色\n2. 黒色\n3. 茶色\n以下のような関数を作成します。\n\n```dart\nDateTime StringToDate(String dateString) {\n    return DateTime.parse(dateString);\n}\n```'),
          finishReason: 'stop',
        )
      ],
      usage: UsageResponse(
        promptTokens: 35,
        completionTokens: 430,
        totalTokens: 465,
      ),
    );
  }
}
