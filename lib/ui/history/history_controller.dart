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
    final threads = await ref.read(historyRepositoryProvider).findAllThread();
    ref.read(historyThreadsStateProvider.notifier).state = threads;
  }

  Future<void> onLoad(int threadId) async {
    final talks = await ref.read(historyRepositoryProvider).findTalks(threadId);
    ref.read(historyTalksStateProvider.notifier).state = talks;
    ref.read(historySelectedThreadIdProvider.notifier).state = threadId;
  }
}

// 履歴のスレッド一覧
final historyThreadsStateProvider = StateProvider<List<TalkThread>>((_) => []);

// 選択中のスレッド
final historySelectedThreadIdProvider = StateProvider<int>((_) => TalkThread.noneId);

// 表示する履歴の会話情報
final historyTalksStateProvider = StateProvider<List<Talk>>((ref) => []);
