import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return const AppSettings();
  }

  void setEmail(String newEmail) {
    state = state.copyWith(email: newEmail);
  }

  void setApiKey(String newApiKey) {
    state = state.copyWith(apiKey: newApiKey);
  }
}

@immutable
class AppSettings {
  // TODO デバッグのためapiKeyの初期値を適当に入れている
  const AppSettings({this.email, this.apiKey = 'test'});

  final String? email;
  final String? apiKey;

  AppSettings copyWith({String? email, String? apiKey}) {
    return AppSettings(
      email: email ?? this.email,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
