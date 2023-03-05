import 'package:assistant_me/data/local/dao/talk_dao.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historyRepositoryProvider = Provider((ref) => HistoryRepository(ref));

class HistoryRepository {
  HistoryRepository(this._ref);

  final Ref _ref;

  Future<List<TalkThread>> findAllThread() async {
    return _ref.read(talkDaoProvider).findAllThread();
  }

  Future<List<Talk>> findTalks(int threadId) async {
    return _ref.read(talkDaoProvider).findTalks(threadId);
  }
}
