import 'package:assistant_me/data/history_repository.dart';
import 'package:assistant_me/model/app_settings.dart';
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
}

// 選択月
final selectedDateStateProvider = StateProvider<DateTime>((_) => DateTime.now());

// 1ドルあたりの円
final yenPerDollar = StateProvider<int>((_) => 140);

// 選択月のトークン数
final totalTokenByMonthProvider = Provider<int>((ref) {
  final threads = ref.watch(threadsByMonthFutureProvider).value;
  if (threads == null) {
    return 0;
  }
  return threads.map((t) => t.totalTalkTokenNum).fold(0, (prev, elem) => prev + elem);
});

// 選択月の金額
final amountByMonthStateProvider = Provider<int>((ref) {
  final yen = ref.watch(yenPerDollar);
  final totalTokenNum = ref.watch(totalTokenByMonthProvider);
  final tokenUnit = ref.watch(appSettingsProvider.select((value) => value.amountPerTokenNum));
  final dollar = ref.watch(appSettingsProvider.select((value) => value.amountDollerPerTokenNum));

  final amountDouble = (totalTokenNum / tokenUnit) * (dollar * yen);
  return amountDouble.round();
});

// 選択月のスレッドリスト
final threadsByMonthFutureProvider = FutureProvider<List<TalkThread>>((ref) async {
  final selectedDate = ref.watch(selectedDateStateProvider);
  return await ref.read(historyRepositoryProvider).findThreadOfMonth(selectedDate);
});
