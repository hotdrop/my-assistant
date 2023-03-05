import 'package:assistant_me/data/history_repository.dart';
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
}

final historyThreadsStateProvider = StateProvider<List<TalkThread>>((_) => []);
