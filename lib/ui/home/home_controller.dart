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
    // TODO この関数実行中は追加でメッセージが来ても無視する
    if (apiKey == null || message.isEmpty) {
      return;
    }
    // TODO TalkのIDをどうするか？スレッドIDと連番にするか。いずれにしろhomeControllerで発行したくない
    int id = 1;

    ref.read(currentTalksProvider.notifier).addUserTalk(id, message);
    ref.read(talkControllerProvider).clear();

    // TODO ここでloading状態にしてresponseが返ってきたら入れ替えたい。
    _autoScrollToEndOfTalkArea();

    final response = await ref.read(assistRepositoryProvider).talk(message, apiKey);
    ref.read(currentTalksProvider.notifier).addAssistantResponse(id, response);
    _autoScrollToEndOfTalkArea();
  }

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

  void addAssistantResponse(int id, GptResponse response) {
    final messageObj = response.choices.first.message;

    final talk = Talk.create(
      id: id,
      dateTime: response.epoch.toDateTime(),
      roleType: Talk.toRoleType(messageObj.role),
      message: messageObj.content,
      totalTokenNum: response.usage.totalTokens,
    );
    state = [...state, talk];
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

// エラー
final errorProvider = Provider<String?>((ref) {
  final appSettings = ref.watch(appSettingsProvider);
  if (appSettings.apiKey == null) {
    return 'API Keyが設定されていません。API Keyを設定してから実行してください。';
  }
  return null;
});
