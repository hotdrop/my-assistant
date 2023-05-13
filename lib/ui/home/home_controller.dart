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

    final message = ref.read(homeTalkControllerProvider).text;
    final system = ref.read(homeSystemInputTextStateProvider);

    if (ref.read(homeThreadProvider).noneTalk()) {
      // 最初の会話だったらスレッドを保存する
      final newThread = await ref.read(assistRepositoryProvider).createThread(system: system, message: message);
      ref.read(homeThreadProvider.notifier).state = newThread;
    } else {
      // 継続会話であればこのタイミングでsystemのみ更新する
      ref.read(homeThreadProvider.notifier).state = ref.read(homeThreadProvider).updateSystem(system);
    }

    // ユーザーの会話追加
    ref.read(homeCurrentTalksProvider.notifier).addUserTalk(message);
    ref.read(homeTalkControllerProvider).clear();

    // アシスタントのロード中会話追加
    ref.read(homeCurrentTalksProvider.notifier).addAssistantLoading();
    _autoScrollToEndOfTalkArea();

    final thread = ref.read(homeThreadProvider);

    // アシスタント側の処理
    await _processAssistant(message, thread);

    // スレッド更新
    final newThread = await ref.read(assistRepositoryProvider).findThread(thread.id);
    ref.read(homeThreadProvider.notifier).state = newThread;

    _autoScrollToEndOfTalkArea();
  }

  Future<void> _processAssistant(String message, TalkThread thread) async {
    final useModel = ref.read(appSettingsProvider).useLlmModel;
    final apiKey = ref.read(appSettingsProvider).apiKey!;

    try {
      switch (useModel) {
        case LlmModel.gpt3:
        case LlmModel.gpt4:
          final talk = await ref.read(assistRepositoryProvider).messageTalk(apiKey: apiKey, thread: thread, message: message);
          ref.read(homeCurrentTalksProvider.notifier).updateAssistantResponse(talk);
          break;
        case LlmModel.dallE:
          final talk = await ref.read(assistRepositoryProvider).imageTalk(
                apiKey: apiKey,
                thread: thread,
                message: message,
                createNum: ref.read(homeCountCreateImagesStateProvider),
              );
          ref.read(homeCurrentTalksProvider.notifier).updateAssistantResponse(talk);
          break;
      }
    } on AppException catch (e) {
      ref.read(_apiErrorMessage.notifier).state = e.message;
      ref.read(homeCurrentTalksProvider.notifier).errorAssistantResponse();
    } catch (e) {
      ref.read(_apiErrorMessage.notifier).state = '$e';
      ref.read(homeCurrentTalksProvider.notifier).errorAssistantResponse();
    }
  }

  ///
  /// 会話の一番下にスクロールする処理
  /// animateToだけだとWidgetにアイテムが追加される前にスクロール処理を行なってしまうのでaddPostFrameCallbackをつけている
  /// 参考: https://stackoverflow.com/questions/44141148/how-to-get-full-size-of-a-scrollcontroller/44142234#44142234
  ///
  void _autoScrollToEndOfTalkArea() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(homeChatScrollControllerProvider).animateTo(
            ref.read(homeChatScrollControllerProvider).position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
    });
  }

  void selectImageCount(int newVal) {
    ref.read(homeCountCreateImagesStateProvider.notifier).state = newVal;
  }

  void setTemplate(String templateContents) {
    ref.read(homeTalkControllerProvider).text = templateContents;
  }

  void selectModel(LlmModel selectValue) {
    ref.read(appSettingsProvider.notifier).selectModel(selectValue);
  }

  void inputSystem(String? value) {
    ref.read(homeSystemInputTextStateProvider.notifier).state = value;
  }

  void newThread() {
    if (!_canContinueProcess()) {
      return;
    }
    final currentModel = ref.read(appSettingsProvider).useLlmModel;

    ref.read(homeThreadProvider.notifier).state = TalkThread.createEmpty(currentModel);
    ref.read(homeCurrentTalksProvider.notifier).clear();
    ref.read(homeTalkControllerProvider).clear();
    ref.read(currentUseTokenStateProvider.notifier).state = 0;
    ref.read(_apiErrorMessage.notifier).state = null;
    ref.read(homeSystemInputTextStateProvider.notifier).state = null;
  }

  ///
  /// ボタン連打で送信しないようにする制御
  /// 以下の場合はfalseを返す。
  /// ・初期状態（会話のメッセージが空で会話のやりとりもない）
  /// ・アシスタント側が会話のロード中
  ///
  bool _canContinueProcess() {
    final emptyMessage = ref.read(homeTalkControllerProvider).text.isEmpty;
    final nonTalk = ref.read(homeCurrentTalksProvider).isEmpty;
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
    if (ref.read(homeCurrentTalksProvider).isEmpty) {
      return false;
    }

    final lastTalk = ref.read(homeCurrentTalksProvider).last;
    return lastTalk.isLoading();
  }

  ///
  /// 履歴画面から会話を再開する場合にこれを呼ぶ
  ///
  Future<void> loadHistoryThread(TalkThread thread, List<Talk> talks) async {
    newThread();
    ref.read(appSettingsProvider.notifier).selectModel(thread.model);
    ref.read(homeThreadProvider.notifier).state = thread;
    ref.read(homeSystemInputTextStateProvider.notifier).state = thread.system;
    ref.read(homeCurrentTalksProvider.notifier).addAll(talks);
    ref.read(currentUseTokenStateProvider.notifier).state = thread.currentTokens;
  }
}

// 会話データのスレッド（会話データに対して1つのスレッドを割り当てる）
final homeThreadProvider = StateProvider((ref) {
  final useModel = ref.watch(appSettingsProvider).useLlmModel;
  return TalkThread.createEmpty(useModel);
});

// 会話データ
final homeCurrentTalksProvider = NotifierProvider<CurrentTalksNotifier, List<Talk>>(CurrentTalksNotifier.new);

class CurrentTalksNotifier extends Notifier<List<Talk>> {
  @override
  List<Talk> build() {
    return [];
  }

  void addUserTalk(String message) {
    final talk = Message.create(
      roleType: RoleType.user,
      value: message,
      tokenNum: 0,
    );
    state = [...state, talk];
  }

  void addAll(List<Talk> talks) {
    state = talks;
  }

  void addAssistantLoading() {
    final talk = Message.loading();
    state = [...state, talk];
  }

  void updateAssistantResponse(Talk talk) {
    final lastIndex = state.length - 1;
    state = List.of(state)..[lastIndex] = talk;
  }

  void errorAssistantResponse() {
    final lastIndex = state.length - 1;
    state = List.of(state)
      ..[lastIndex] = Message.create(
        roleType: RoleType.assistant,
        value: 'エラーが発生しました。お手数をおかけしますが、会話入力欄の下のエラー内容をご確認ください。',
        tokenNum: 0,
      );
  }

  void clear() {
    state = [];
  }
}

// 会話入力フィールド
final homeTalkControllerProvider = StateProvider<TextEditingController>((ref) {
  final controller = TextEditingController();
  controller.addListener(() {
    ref.read(homeIsInputTextEmpty.notifier).state = controller.text.isEmpty;
  });
  return controller;
});

// 入力フィールドのリスナー
final homeIsInputTextEmpty = StateProvider((_) => true);

// 会話は上から下方向に時系列で進んでいくのでスクロールを常に一番下に移動させるためこれを定義する
final homeChatScrollControllerProvider = StateProvider((_) => ScrollController());

// 入力枠の下に表示するエラーメッセージ
final homeErrorProvider = Provider<String?>((ref) {
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

// 画像モデルを選択しているか？
final homeIsSelectDallEModelProvider = Provider((ref) {
  return ref.watch(appSettingsProvider).isDallEModel;
});

// 生成する画像枚数
final homeCountCreateImagesStateProvider = StateProvider<int>((_) => 1);

// system
final homeSystemInputTextStateProvider = StateProvider<String?>((_) => null);
