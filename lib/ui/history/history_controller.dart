import 'package:assistant_me/data/history_repository.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_controller.g.dart';

@riverpod
class HistoryController extends _$HistoryController {
  @override
  Future<void> build() async {
    _refresh();
  }

  Future<void> onLoad(int threadId) async {
    final talks = await ref.read(historyRepositoryProvider).findTalks(threadId);
    ref.read(historyTalksStateProvider.notifier).state = talks;
    ref.read(historySelectedThreadIdProvider.notifier).state = threadId;
  }

  Future<void> delete(int threadId) async {
    await ref.read(historyRepositoryProvider).delete(threadId);
    ref.read(historyTalksStateProvider.notifier).state = [];
    ref.read(historySelectedThreadIdProvider.notifier).state = TalkThread.noneId;
    await _refresh();
  }

  Future<void> _refresh() async {
    final threads = await ref.read(historyRepositoryProvider).findAllThread();
    ref.read(historyThreadsStateProvider.notifier).state = threads;
  }
}

// 履歴のスレッド一覧
final historyThreadsStateProvider = StateProvider<List<TalkThread>>((_) => []);

// 選択中のスレッドID
final historySelectedThreadIdProvider = StateProvider<int>((_) => TalkThread.noneId);

// 選択中のスレッド
final historySelectedThreadProvider = Provider<TalkThread?>((ref) {
  final currentThreadId = ref.watch(historySelectedThreadIdProvider);
  final currentThreads = ref.watch(historyThreadsStateProvider).where((t) => t.id == currentThreadId).toList();
  if (currentThreads.isEmpty) {
    return null;
  }
  return currentThreads.first;
});

// 表示する履歴の会話情報
final historyTalksStateProvider = StateProvider<List<Talk>>((ref) => []);
