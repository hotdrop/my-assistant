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
  const AppSettings({this.apiKey, this.maxTokenNum = maxToken});

  final String? apiKey;
  final int maxTokenNum;

  static const int maxToken = 4096;

  AppSettings copyWith({String? apiKey, int? maxTokenNum}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      maxTokenNum: maxTokenNum ?? this.maxTokenNum,
    );
  }
}
