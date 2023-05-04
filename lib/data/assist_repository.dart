import 'package:assistant_me/data/local/dao/talk_dao.dart';
import 'package:assistant_me/data/remote/entities/gpt_error_response.dart';
import 'package:assistant_me/data/remote/entities/gpt_image_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_request.dart';
import 'package:assistant_me/data/remote/entities/gpt_response.dart';
import 'package:assistant_me/data/remote/http_client.dart';
import 'package:assistant_me/model/app_exception.dart';
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
  Future<TalkThread> createThread({String? system, required String message}) async {
    final useModel = _ref.read(appSettingsProvider).useLlmModel;
    return await _ref.read(talkDaoProvider).createThread(useModel: useModel, message: message, system: system);
  }

  Future<TalkThread> findThread(int id) async {
    return await _ref.read(talkDaoProvider).findThread(id);
  }

  ///
  /// メッセージを取得する
  ///
  Future<Message> messageTalk({required String apiKey, required TalkThread thread, required String message}) async {
    final historyTalks = await _ref.read(talkDaoProvider).findMessageTalks(thread.id);
    final request = GptRequest.create(
      apiKey: apiKey,
      system: thread.system,
      message: message,
      histories: historyTalks,
      useModel: _ref.read(appSettingsProvider).useLlmModel,
    );

    final result = await _ref.read(httpClientProvider).post(request);
    return result.when(
      success: (res) => _onSuccessMessageTalk(res, thread, message, request.currentTotalTokenNum),
      error: (res) => _onErrorMessageTalk(res, request, thread),
    );
  }

  Future<Message> _onSuccessMessageTalk(GptResponse response, TalkThread thread, String message, int currentTotalTokenNum) async {
    // <注意！>
    // ・Threadには消費トークン数を保持する
    // ・Talkには個々のTalkが使用したトークン数を保持する（APIからは合計トークンが返ってくるので差し引いて保存する）
    final talk = Message.create(
      roleType: Talk.toRoleType(response.choices.first.message.role),
      value: response.choices.first.message.content,
      tokenNum: response.usage.totalTokens - currentTotalTokenNum,
    );

    await _ref.read(talkDaoProvider).save(
          threadId: thread.id,
          message: message,
          system: thread.system,
          talk: talk,
          currentTotalTokens: response.usage.totalTokens,
        );

    // 現在のトークンを更新する
    _ref.read(currentUseTokenStateProvider.notifier).state = response.usage.totalTokens;

    return talk;
  }

  Future<Message> _onErrorMessageTalk(GptErrorResponse response, GptRequest request, TalkThread thread) async {
    // 使用モデルのトークン数超過以外のエラーはそのまま例外で返す
    if (!response.error.isOverTokenError()) {
      throw AppException(message: 'APIでエラーが発生しました。\n code: ${response.error.code} message: ${response.error.message}');
    }

    // トークン数超過の場合、超過した使用トークン数（gpt3.5なら4765など）がエラーメッセージに載っているのでそれを取得する
    final overTokenNum = response.error.getOverTokenNum();

    // 超過したトークンが過去の履歴全部削除しても超過してしまう状況＝1会話だけで選択したモデルの許容トークン数を超過してしまう状況
    // こんなことはほぼないと思うが、このケースが発生した場合はループしないよう例外で返す
    if (overTokenNum >= request.useModel.maxContext * 2) {
      throw AppException(message: 'APIでエラーが発生しました。必要な最大トークン数が許容トークン数を遙かに超えています。 $overTokenNum');
    }

    // 履歴を削るのはRequestクラスがやってくれるので超過した総トークン数を渡して新しいRequestでリトライする
    final newRequest = GptRequest.create(
      apiKey: request.apiKey,
      system: request.system,
      message: request.newContents,
      histories: request.histories,
      useModel: request.useModel,
      overTokenNum: overTokenNum,
    );

    final result = await _ref.read(httpClientProvider).post(newRequest);
    return result.when(
      success: (res) => _onSuccessMessageTalk(res, thread, newRequest.newContents, newRequest.currentTotalTokenNum),
      error: (res) => throw AppException(message: 'APIでエラーが発生しました。\n code: ${res.error.code} message: ${res.error.message}'),
    );
  }

  ///
  /// イメージ画像を取得する
  ///
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
}
