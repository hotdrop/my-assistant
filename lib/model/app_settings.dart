import 'package:assistant_me/data/local/local_data_source.dart';
import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/template.dart';
import 'package:assistant_me/ui/top_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void selectModel(LlmModel model) {
    state = state.copyWith(useLlmModel: model);
  }
}

@immutable
class AppSettings {
  const AppSettings({
    this.apiKey,
    this.useLlmModel = LlmModel.gpt3,
  });

  // API Key
  final String? apiKey;
  // 利用対象のモデル
  final LlmModel useLlmModel;

  // 最大トークン数を取得
  int get maxTokensNum => useLlmModel.maxContext;
  // 画像モデルかどうか？
  bool get isDallEModel => useLlmModel == LlmModel.dallE;

  AppSettings copyWith({String? apiKey, LlmModel? useLlmModel}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      useLlmModel: useLlmModel ?? this.useLlmModel,
    );
  }
}

// TopPageでどの画面のメニューを表示するか
final selectPageIndexProvider = StateProvider<int>((_) => TopPage.homeIndex);
