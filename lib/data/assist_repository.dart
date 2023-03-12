import 'package:assistant_me/common/logger.dart';
import 'package:assistant_me/data/local/dao/talk_dao.dart';
import 'package:assistant_me/data/remote/entities/gpt_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_response.dart';
import 'package:assistant_me/data/remote/http_client.dart';
import 'package:assistant_me/model/app_settings.dart';
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
      systemRoles: _ref.read(appSettingsProvider).systemMessages,
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
                  'Dartでは、DateTimeクラスを使用して、文字列をDate型に変換することができます。以下は、引数の文字列をDate型に変換する関数の例です。\n\n```\nDateTime parseDate(String dateStr) {\n  // Date format: "yyyy-MM-dd"\n  var format = DateFormat(\'yyyy-MM-dd\');\n  return format.parse(dateStr);\n}\n```\n\nこの関数は、引数で与えられたdateStrを指定された形式の日付に変換し、DateTime型で返します。DateFormatクラスを使用して、yyyy-MM-dd形式の日付をパースしています。この形式は、例えば「2023-03-11」といった日付の形式になります。引数の日付フォーマットに応じて、使用するフォーマットを変更する必要があります。\n\n例えば、"2023-03-11"という文字列を引数として渡すと、DateTimeオブジェクトとして返されます。\n'),
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
