import 'package:assistant_me/data/local/local_data_source.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// アプリ起動時の初期化処理を行う
final appInitFutureProvider = FutureProvider<void>((ref) async {
  await ref.read(localDataSourceProvider).init();
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
    this.maxTokenNum = 4096,
    this.amountPerTokenNum = 1000,
    this.amountDollerPerTokenNum = 0.002,
  });

  final String? apiKey;
  // 最大トークン数 コンストラクタで設定している値は2023年1月現在の最大数
  final int maxTokenNum;
  // 金額算出時に使用するトークン単位 コンストラクタで設定している値は2023/1現在のもの
  final int amountPerTokenNum;
  // 上記トークン単位の金額（ドル） コンストラクタで設定している値は2023/1現在のもの
  final double amountDollerPerTokenNum;

  AppSettings copyWith({String? apiKey}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
