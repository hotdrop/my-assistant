import 'package:assistant_me/data/history_repository.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_detail_controller.g.dart';

@riverpod
class HistoryDetailController extends _$HistoryDetailController {
  @override
  Future<void> build(int threadId) async {
    final talks = await ref.read(historyRepositoryProvider).findTalks(threadId);
    ref.read(talksStateProvider.notifier).state = talks;
  }
}

final talksStateProvider = StateProvider<List<Talk>>((ref) => []);
