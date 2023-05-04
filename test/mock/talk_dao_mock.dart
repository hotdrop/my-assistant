import 'package:assistant_me/data/local/dao/talk_dao.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/llm_model.dart';

class TalkDaoMock implements TalkDao {
  @override
  Future<TalkThread> createThread({required LlmModel useModel, String? system, required String message}) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete({required int threadId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Talk>> findAllTalks(int threadId) {
    throw UnimplementedError();
  }

  @override
  Future<List<TalkThread>> findAllThread() {
    throw UnimplementedError();
  }

  @override
  Future<List<Message>> findMessageTalks(int threadId) {
    return Future.value([
      Message(RoleType.user, '最初の会話です', 0),
      Message(RoleType.assistant, '最初の会話の回答です', 100),
      Message(RoleType.user, '2番目の会話です', 0),
      Message(RoleType.assistant, '2番目の会話の回答です', 1000),
      Message(RoleType.user, '3番目の会話です', 0),
      Message(RoleType.assistant, '3番目の会話の回答です', 1500),
      Message(RoleType.user, '4番目の会話です', 0),
      Message(RoleType.assistant, '4番目の会話の回答です', 1500),
      Message(RoleType.user, '5番目の会話です', 0),
      Message(RoleType.assistant, '5番目の会話の回答です', 1000),
    ]);
  }

  @override
  Future<TalkThread> findThread(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<int>> findThreadIDsByKeywordInTalkMessage(String searchWord) {
    throw UnimplementedError();
  }

  @override
  Future<void> save({
    required int threadId,
    required String message,
    required String? system,
    required Message talk,
    required int currentTotalTokens,
  }) async {
    // 保存は何もしない
  }

  @override
  Future<void> saveImageTalk({required int threadId, required String message, required List<String> iamgeUrls}) {
    throw UnimplementedError();
  }
}
