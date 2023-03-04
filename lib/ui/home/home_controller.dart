import 'package:assistant_me/data/assist_repository.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/model/gpt_response.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:flutter/material.dart';
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
    if (apiKey == null || message.isEmpty) {
      return;
    }
    // TODO TalkのIDをどうするか？一意にしたいので別の場所から発行してくるか時刻のEpochにするか
    int id = 1;

    ref.read(currentTalksProvider.notifier).addUserTalk(id, message);
    ref.read(talkControllerProvider).clear();
    // TODO ここでloading状態にしてresponseが返ってきたら入れ替えたい。

    final response = await ref.read(assistRepositoryProvider).talk(message, apiKey);
    ref.read(currentTalksProvider.notifier).addAssistantResponse(id, response);
  }
}

final currentTalksProvider = NotifierProvider<CurrentTalksNotifier, List<Talk>>(CurrentTalksNotifier.new);

class CurrentTalksNotifier extends Notifier<List<Talk>> {
  @override
  List<Talk> build() {
    return [];
  }

  void addUserTalk(int id, String message) {
    final talk = Talk(
      id: id,
      roleType: RoleType.user,
      message: message,
      totalTokenNum: 0,
    );
    state = [...state, talk];
  }

  void addAssistantResponse(int id, GptResponse response) {
    final messageObj = response.choices.first.message;
    final usage = response.usage;

    final roleType = Talk.toRoleType(messageObj.role);
    final talk = Talk(id: id, roleType: roleType, message: messageObj.content, totalTokenNum: usage.totalTokens);
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

// エラー
final errorProvider = Provider<String?>((ref) {
  final appSettings = ref.watch(appSettingsProvider);
  if (appSettings.apiKey == null) {
    return 'API Keyが設定されていません。API Keyを設定してから実行してください。';
  }
  return null;
});
