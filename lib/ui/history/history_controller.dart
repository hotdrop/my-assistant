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
    await ref.read(historyThreadsProvider.notifier).onLoad();
  }

  Future<void> onLoadTalks(int threadId) async {
    final talks = await ref.read(historyRepositoryProvider).findTalks(threadId);
    ref.read(historyTalksStateProvider.notifier).state = talks;
    ref.read(historySelectedThreadIdProvider.notifier).state = threadId;
  }

  Future<void> deleteThread(int threadId) async {
    await ref.read(historyRepositoryProvider).delete(threadId);
    ref.read(historyTalksStateProvider.notifier).state = [];
    ref.read(historySelectedThreadIdProvider.notifier).state = TalkThread.noneId;
    ref.read(historyThreadsProvider.notifier).removeThread(threadId);
  }

  void inputSearchText(String? text) {
    ref.read(historyThreadsProvider.notifier).searchText(text);
    ref.read(historyTalksStateProvider.notifier).state = [];
    ref.read(historySelectedThreadIdProvider.notifier).state = TalkThread.noneId;
  }

  void changeDateSort() {
    final isAsc = ref.read(historyCreateAtOrderAscStateProvider);
    ref.read(historyThreadsProvider.notifier).sort(!isAsc);
    ref.read(historyCreateAtOrderAscStateProvider.notifier).state = !isAsc;
  }
}

// 日付の昇順・昇順ソート
final historyCreateAtOrderAscStateProvider = StateProvider<bool>((_) => true);

// 選択中のスレッドID
final historySelectedThreadIdProvider = StateProvider<int>((_) => TalkThread.noneId);

// 選択中のスレッド
final historySelectedThreadProvider = Provider<TalkThread?>((ref) {
  final currentThreadId = ref.watch(historySelectedThreadIdProvider);
  final currentThreads = ref.watch(historyThreadsProvider).where((t) => t.id == currentThreadId).toList();
  if (currentThreads.isEmpty) {
    return null;
  }
  return currentThreads.first;
});

// 表示する履歴の会話情報
final historyTalksStateProvider = StateProvider<List<Talk>>((ref) => []);

// 表示用の履歴スレッド一覧
final historyThreadsProvider = NotifierProvider<HistoryThreadsNotifier, List<TalkThread>>(HistoryThreadsNotifier.new);

class HistoryThreadsNotifier extends Notifier<List<TalkThread>> {
  @override
  List<TalkThread> build() {
    return [];
  }

  List<TalkThread> _original = [];

  Future<void> onLoad() async {
    final threads = await ref.read(historyRepositoryProvider).findAllThread();
    _original = threads;
    state = threads;
  }

  void sort(bool isAsc) {
    final tmp = state;
    if (isAsc) {
      tmp.sort((a, b) => a.createAt.compareTo(b.createAt));
    } else {
      tmp.sort((a, b) => b.createAt.compareTo(a.createAt));
    }
    state = [...tmp];
  }

  void removeThread(int threadId) {
    final current = state;
    _original.removeWhere((thread) => thread.id == threadId);
    current.removeWhere((thread) => thread.id == threadId);
    state = [...current];
  }

  Future<void> searchText(String? text) async {
    if (text == null || text.isEmpty) {
      // TODO この実装だとソート状態が維持されないので修正が必要
      state = [..._original];
      return;
    }

    final targetThreadIds = await ref.read(historyRepositoryProvider).findThreadIdsByKeyword(text);
    final newState = state.where((t) => targetThreadIds.contains(t.id)).toList();
    state = [...newState];
  }
}
