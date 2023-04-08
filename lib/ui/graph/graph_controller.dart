import 'package:assistant_me/data/history_repository.dart';
import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'graph_controller.g.dart';

@riverpod
class GraphController extends _$GraphController {
  @override
  void build() {}

  void setSelectedDate(DateTime? newDate) {
    if (newDate == null) {
      return;
    }
    ref.read(selectedDateStateProvider.notifier).state = newDate;
  }

  void setYenPerDollar(String yenStr) {
    final yen = int.tryParse(yenStr);
    if (yen == null) {
      return;
    }
    ref.read(yenPerDollar.notifier).state = yen;
  }

  void refresh() {
    ref.invalidate(threadsByMonthFutureProvider);
  }
}

// 選択月
final selectedDateStateProvider = StateProvider<DateTime>((_) => DateTime.now());

// 1ドルあたりの円
final yenPerDollar = StateProvider<int>((_) => 140);

// 選択月のスレッドリスト
final threadsByMonthFutureProvider = FutureProvider<List<TalkThread>>((ref) async {
  final selectedDate = ref.watch(selectedDateStateProvider);
  return await ref.read(historyRepositoryProvider).findThreadOfMonth(selectedDate);
});

// 画面に表示する総トークン数
final totalTokenNumProvider = Provider((ref) {
  final tokenGpt3 = ref.watch(_tokenNumGpt3ByMonthProvider);
  final tokenGpt4 = ref.watch(_tokenNumGpt4ByMonthProvider);
  return tokenGpt3 + tokenGpt4;
});

// 画面に表示する利用料金
final amountByMonthProvider = Provider((ref) {
  final yen = ref.watch(yenPerDollar);
  // モデル別の利用料金
  final amountGpt3 = LlmModel.calcAmount(llmModel: LlmModel.gpt3, tokenNum: ref.watch(_tokenNumGpt3ByMonthProvider), yen: yen);
  final amountGpt4 = LlmModel.calcAmount(llmModel: LlmModel.gpt4, tokenNum: ref.watch(_tokenNumGpt4ByMonthProvider), yen: yen);
  // 算出したモデル別の金額の合計
  return amountGpt3 + amountGpt4;
});

// 選択した月のGPT3モデルの総使用トークン数
final _tokenNumGpt3ByMonthProvider = Provider<int>((ref) {
  final threads = ref.watch(threadsByMonthFutureProvider).value?.where((t) => t.llmModel == LlmModel.gpt3);
  if (threads == null) {
    return 0;
  }
  return threads.map((e) => e.totalTalkTokenNum).fold(0, (prev, elem) => prev + elem);
});

// 選択した月のGPT4モデルの総使用トークン数
final _tokenNumGpt4ByMonthProvider = Provider<int>((ref) {
  final gpt4Threads = ref.watch(threadsByMonthFutureProvider).value?.where((t) => t.llmModel == LlmModel.gpt4);
  if (gpt4Threads == null) {
    return 0;
  }
  return gpt4Threads.map((e) => e.totalTalkTokenNum).fold(0, (prev, elem) => prev + elem);
});
