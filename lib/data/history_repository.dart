import 'package:assistant_me/common/extension.dart';
import 'package:assistant_me/common/logger.dart';
import 'package:assistant_me/data/local/dao/talk_dao.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historyRepositoryProvider = Provider((ref) => HistoryRepository(ref));

class HistoryRepository {
  HistoryRepository(this._ref);

  final Ref _ref;

  Future<List<TalkThread>> findAllThread() async {
    return await _ref.read(talkDaoProvider).findAllThread();
  }

  Future<List<TalkThread>> findThreadOfMonth(DateTime targetDate) async {
    final startAt = targetDate.getStartOfMonth();
    final endAt = targetDate.getEndOfMonth();
    AppLogger.d('$startAt 〜 $endAtのスレッド情報を取得します');
    return await _ref.read(talkDaoProvider).findRangeThread(from: startAt, to: endAt);
  }

  Future<List<Talk>> findTalks(int threadId) async {
    return await _ref.read(talkDaoProvider).findTalks(threadId);
  }

  Future<void> delete(int threadId) async {
    await _ref.read(talkDaoProvider).delete(threadId: threadId);
  }
}
