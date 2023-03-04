import 'package:assistant_me/common/logger.dart';
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
    final messageController = ref.read(talkControllerProvider);
    if (apiKey == null || messageController.text.isEmpty) {
      return;
    }

    final response = await ref.read(assistRepositoryProvider).talk(messageController.text, apiKey);
    ref.read(currentTalksProvider.notifier).add(response);
    ref.read(talkControllerProvider).clear();
  }
}

final currentTalksProvider = NotifierProvider<CurrentTalksNotifier, List<Talk>>(CurrentTalksNotifier.new);

class CurrentTalksNotifier extends Notifier<List<Talk>> {
  @override
  List<Talk> build() {
    return [];
  }

  void add(GptResponse response) {
    final messageObj = response.choices.first.message;
    final usage = response.usage;

    final roleType = Talk.toRoleType(messageObj.role);
    final talk = Talk(id: response.id, roleType: roleType, talk: messageObj.content, totalTokenNum: usage.totalTokens);
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
