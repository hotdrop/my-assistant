import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  // TODO デバッグのためapiKeyの初期値を適当に入れているが本来は不要
  const AppSettings({this.apiKey = 'test'});

  final String? apiKey;

  AppSettings copyWith({String? email, String? apiKey}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
