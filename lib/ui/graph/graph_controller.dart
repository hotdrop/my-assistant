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

// 画面に表示する利用料金
final amountByMonthProvider = Provider((ref) {
  final amountGpt3 = ref.watch(_useAmountGpt3ByMonthProvider);
  final amountGpt4 = ref.watch(_useAmountGpt4ByMonthProvider);
  return amountGpt3 + amountGpt4;
});

// 選択した月のGPT3モデルの総利用料
final _useAmountGpt3ByMonthProvider = Provider<int>((ref) {
  final yen = ref.watch(yenPerDollar);
  final threads = ref.watch(threadsByMonthFutureProvider).value?.where((t) => t.model == LlmModel.gpt3);
  if (threads == null) {
    return 0;
  }
  return threads.map((e) => e.calcAmount(yen: yen)).fold(0, (prev, elem) => prev + elem);
});

// 選択した月のGPT4モデルの総利用料
final _useAmountGpt4ByMonthProvider = Provider<int>((ref) {
  final yen = ref.watch(yenPerDollar);
  final gpt4Threads = ref.watch(threadsByMonthFutureProvider).value?.where((t) => t.model == LlmModel.gpt4);
  if (gpt4Threads == null) {
    return 0;
  }
  return gpt4Threads.map((e) => e.calcAmount(yen: yen)).fold(0, (prev, elem) => prev + elem);
});
