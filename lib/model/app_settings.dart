import 'package:assistant_me/data/local/local_data_source.dart';
import 'package:assistant_me/model/template.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// アプリ起動時の初期化処理を行う
final appInitFutureProvider = FutureProvider<void>((ref) async {
  await ref.read(localDataSourceProvider).init();
  await ref.read(templateNotifierProvider.notifier).onLoad();
});

// アプリ設定
final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return const AppSettings();
  }

  void setApiKey(String newApiKey) {
    state = state.copyWith(apiKey: newApiKey);
  }
}

@immutable
class AppSettings {
  const AppSettings({
    this.apiKey,
    this.systemMessages,
    this.maxTokensNum = 4096 - 300, // 最大トークンにすると1会話分削ってもエラーになる可能性があるので余裕を見る
    this.amountPerTokenNum = 1000,
    this.amountDollerPerTokenNum = 0.002,
  });

  // API Key
  final String? apiKey;
  // GhatGPT APIを使うときのsystem Roleに設定する文字列。今のところ役に立たないので空にする
  final List<Map<String, String>>? systemMessages;
  // 最大トークン数
  final int maxTokensNum;
  // 金額算出時に使用するトークン単位 コンストラクタで設定している値は2023/1現在のもの
  final int amountPerTokenNum;
  // 上記トークン単位の金額（ドル） コンストラクタで設定している値は2023/1現在のもの
  final double amountDollerPerTokenNum;

  AppSettings copyWith({String? apiKey, List<Map<String, String>>? systemMessages}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      systemMessages: systemMessages ?? this.systemMessages,
    );
  }
}
