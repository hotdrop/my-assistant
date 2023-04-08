import 'package:assistant_me/data/assist_repository.dart';
import 'package:assistant_me/model/app_exception.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  void build() {}

  Future<void> postTalk() async {
    if (!_canContinueProcess()) {
      return;
    }
    // エラーをクリア
    ref.invalidate(_apiErrorMessage);

    final apiKey = ref.read(appSettingsProvider).apiKey;
    final message = ref.read(talkControllerProvider).text;

    // 最初の会話だったらスレッドを保存する
    if (ref.read(threadProvider).isNotCrerateId()) {
      final thread = await ref.read(assistRepositoryProvider).createThread(message);
      ref.read(threadProvider.notifier).state = thread;
    }
    final thread = ref.read(threadProvider);

    // ユーザーの会話追加
    ref.read(currentTalksProvider.notifier).addUserTalk(message);
    ref.read(talkControllerProvider).clear();

    // アシスタントのロード中会話追加
    ref.read(currentTalksProvider.notifier).addAssistantLoading();
    _autoScrollToEndOfTalkArea();

    // アシスタントのレスポンス会話更新
    try {
      final talk = await ref.read(assistRepositoryProvider).talk(message, apiKey!, thread);
      ref.read(currentTalksProvider.notifier).updateAssistantResponse(talk);
    } on AppException catch (e) {
      ref.read(_apiErrorMessage.notifier).state = e.message;
      ref.read(currentTalksProvider.notifier).errorAssistantResponse();
    } catch (e) {
      ref.read(_apiErrorMessage.notifier).state = '$e';
      ref.read(currentTalksProvider.notifier).errorAssistantResponse();
    }

    // スレッド更新
    final newThread = await ref.read(assistRepositoryProvider).findThread(thread.id);
    ref.read(threadProvider.notifier).state = newThread;

    _autoScrollToEndOfTalkArea();
  }

  ///
  /// 会話の一番下にスクロールする処理
  /// animateToだけだとWidgetにアイテムが追加される前にスクロール処理を行なってしまうのでaddPostFrameCallbackをつけている
  /// 参考: https://stackoverflow.com/questions/44141148/how-to-get-full-size-of-a-scrollcontroller/44142234#44142234
  ///
  void _autoScrollToEndOfTalkArea() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(chatScrollControllerProvider).animateTo(
            ref.read(chatScrollControllerProvider).position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
    });
  }

  void newThread() {
    if (!_canContinueProcess()) {
      return;
    }
    final currentModel = ref.read(appSettingsProvider).useLlmModel;

    ref.read(threadProvider.notifier).state = TalkThread.createEmpty(currentModel);
    ref.read(currentTalksProvider.notifier).clear();
    ref.read(talkControllerProvider).clear();
    ref.read(_apiErrorMessage.notifier).state = null;
  }

  ///
  /// ボタン連打で送信しないようにする制御
  /// 以下の場合はfalseを返す。
  /// ・初期状態（会話のメッセージが空で会話のやりとりもない）
  /// ・アシスタント側が会話のロード中
  ///
  bool _canContinueProcess() {
    final emptyMessage = ref.read(talkControllerProvider).text.isEmpty;
    final nonTalk = ref.read(currentTalksProvider).isEmpty;
    final isAssistantLoading = _isNowLoadingAssistant();

    if ((emptyMessage && nonTalk) || isAssistantLoading) {
      return false;
    }

    return true;
  }

  ///
  /// アシスタントがロード中か？
  ///
  bool _isNowLoadingAssistant() {
    if (ref.read(currentTalksProvider).isEmpty) {
      return false;
    }

    final lastTalk = ref.read(currentTalksProvider).last;
    return lastTalk.isLoading();
  }

  void setTemplate(String templateContents) {
    ref.read(talkControllerProvider).text = templateContents;
  }

  void selectModel(LlmModel selectValue) {
    ref.read(appSettingsProvider.notifier).selectModel(selectValue);
  }
}

// 会話データのスレッド（会話データに対して1つのスレッドを割り当てる）
final threadProvider = StateProvider((ref) {
  final useModel = ref.watch(appSettingsProvider).useLlmModel;
  return TalkThread.createEmpty(useModel);
});

// 会話データ
final currentTalksProvider = NotifierProvider<CurrentTalksNotifier, List<Talk>>(CurrentTalksNotifier.new);

class CurrentTalksNotifier extends Notifier<List<Talk>> {
  @override
  List<Talk> build() {
    return [];
  }

  void addUserTalk(String message) {
    final talk = Talk.create(
      roleType: RoleType.user,
      message: message,
      tokenNum: 0,
    );
    state = [...state, talk];
  }

  void addAssistantLoading() {
    final talk = Talk.loading();
    state = [...state, talk];
  }

  void updateAssistantResponse(Talk talk) {
    final lastIndex = state.length - 1;
    state = List.of(state)..[lastIndex] = talk;
  }

  void errorAssistantResponse() {
    final lastIndex = state.length - 1;
    state = List.of(state)
      ..[lastIndex] = const Talk(
        roleType: RoleType.assistant,
        message: 'エラーが発生しました。お手数をおかけしますが、会話入力欄の下のエラー内容をご確認ください。',
        tokenNum: 0,
      );
  }

  void clear() {
    state = [];
  }
}

// 会話入力フィールド
final talkControllerProvider = StateProvider<TextEditingController>((ref) {
  final controller = TextEditingController();
  controller.addListener(() {
    ref.read(isInputTextEmpty.notifier).state = controller.text.isEmpty;
  });
  return controller;
});

// 入力フィールドのリスナー
final isInputTextEmpty = StateProvider((_) => true);

// 会話は上から下方向に時系列で進んでいくのでスクロールを常に一番下に移動させるためこれを定義する
final chatScrollControllerProvider = StateProvider((_) => ScrollController());

// 入力枠の下に表示するエラーメッセージ
final errorProvider = Provider<String?>((ref) {
  final apiKey = ref.watch(appSettingsProvider.select((value) => value.apiKey));
  final apiErrorMessage = ref.watch(_apiErrorMessage);

  if (apiKey == null || apiKey.isEmpty) {
    return 'API Keyが設定されていません。左のメニューから設定ページを開き設定してください。';
  } else if (apiErrorMessage != null) {
    return apiErrorMessage;
  }
  return null;
});

// APIのエラー
final _apiErrorMessage = StateProvider<String?>((_) => null);
