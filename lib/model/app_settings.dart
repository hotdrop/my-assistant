import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return const AppSettings();
  }

  void setApiKey(String apiKey) {
    state = state.copyWith(apiKey: apiKey);
  }
}

@immutable
class AppSettings {
  const AppSettings({this.apiKey});

  final String? apiKey;

  AppSettings copyWith({String? apiKey}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
