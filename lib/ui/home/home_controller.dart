import 'package:assistant_me/data/assist_repository.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/model/gpt_response.dart';
import 'package:assistant_me/model/talk.dart';
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
    final apiKey = ref.read(appSettingsProvider).apiKey;
    final message = ref.read(talkControllerProvider).text;
    final isAssistantLoading = _isNowLoadingAssistant();

    if (apiKey == null || message.isEmpty || isAssistantLoading) {
      return;
    }

    // TODO TalkのIDをどうするか？スレッドIDと連番にするか。いずれにしろhomeControllerで発行したくない
    int id = 1;

    // こちらの会話追加
    ref.read(currentTalksProvider.notifier).addUserTalk(id, message);
    ref.read(talkControllerProvider).clear();

    // アシスタントのロード中会話追加
    ref.read(currentTalksProvider.notifier).addAssistantLoading(id);
    _autoScrollToEndOfTalkArea();

    // アシスタントのレスポンス会話更新
    final response = await ref.read(assistRepositoryProvider).talk(message, apiKey);
    ref.read(currentTalksProvider.notifier).updateAssistantResponse(id, response);
    _autoScrollToEndOfTalkArea();
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
}

// 会話データ
final currentTalksProvider = NotifierProvider<CurrentTalksNotifier, List<Talk>>(CurrentTalksNotifier.new);

class CurrentTalksNotifier extends Notifier<List<Talk>> {
  @override
  List<Talk> build() {
    return [];
  }

  void addUserTalk(int id, String message) {
    final talk = Talk.create(
      id: id,
      dateTime: DateTime.now(),
      roleType: RoleType.user,
      message: message,
      totalTokenNum: 0,
    );
    state = [...state, talk];
  }

  void addAssistantLoading(int id) {
    final talk = Talk.loading();
    state = [...state, talk];
  }

  void updateAssistantResponse(int id, GptResponse response) {
    final messageObj = response.choices.first.message;

    final talk = Talk.create(
      id: id,
      dateTime: response.epoch.toDateTime(),
      roleType: Talk.toRoleType(messageObj.role),
      message: messageObj.content,
      totalTokenNum: response.usage.totalTokens,
    );
    final lastIndex = state.length - 1;
    state = List.of(state)..[lastIndex] = talk;
  }
}

// 会話入力フィールド
final talkControllerProvider = StateProvider<TextEditingController>((_) => TextEditingController());

// このスレッドの総トークン数
final totalTokenNumProvider = Provider((ref) {
  final currentTalks = ref.watch(currentTalksProvider);
  return currentTalks.map((e) => e.totalTokenNum).fold(0, (value, element) => value + element);
});

// 会話は上から下方向に時系列で進んでいくのでスクロールを常に一番下に移動させるためこれを定義する
final chatScrollControllerProvider = StateProvider((_) => ScrollController());

// 入力枠の下に表示するエラーメッセージ。今のところAPIKeyのエラーしかない
final errorProvider = Provider<String?>((ref) {
  final appSettings = ref.watch(appSettingsProvider);
  if (appSettings.apiKey == null) {
    return 'API Keyが設定されていません。API Keyを設定してから実行してください。';
  }
  return null;
});
