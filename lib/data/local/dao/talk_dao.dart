import 'package:assistant_me/data/local/dao/id_dao.dart';
import 'package:assistant_me/data/local/entities/talk_entity.dart';
import 'package:assistant_me/data/local/entities/talk_thread_entity.dart';
import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final talkDaoProvider = Provider((ref) => TalkDao(ref));

class TalkDao {
  const TalkDao(this._ref);

  final Ref _ref;

  ///
  /// スレッドを新規生成する
  ///
  Future<TalkThread> createThread(String message, LlmModel useModel) async {
    final box = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);

    // スレッドに表示するタイトルは一旦最初の会話の先頭30文字としている。タイトルは変更できるようにした方がよさそう
    final title = message.length < 30 ? message : message.substring(0, 30);

    final newThreadId = await _ref.read(idDaoProvider).generate();
    final talkThread = TalkThreadEntity(
      id: newThreadId,
      llmModelName: useModel.name,
      createAt: DateTime.now(),
      title: title,
      currentTokenNum: 0,
      totalTalkTokenNum: 0,
    );
    box.put(newThreadId, talkThread);

    return _toThreadModel(talkThread);
  }

  ///
  /// 登録されているスレッドを取得する
  ///
  Future<TalkThread> findThread(int id) async {
    final box = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);
    final threadEntity = box.values.where((e) => e.id == id).first;
    return _toThreadModel(threadEntity);
  }

  ///
  /// 登録されているスレッドを全て取得する
  ///
  Future<List<TalkThread>> findAllThread() async {
    final box = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);
    if (box.isEmpty) {
      return [];
    }
    return box.values.map((thread) => _toThreadModel(thread)).toList();
  }

  ///
  /// スレッドに対応するメッセージ形式の会話履歴を全て取得する
  ///
  Future<List<Message>> findMessageTalks(int threadId) async {
    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);
    if (talkBox.isEmpty) {
      return [];
    }

    return talkBox.values //
        .where((t) => t.threadId == threadId)
        .where((t) => t.roleTypeIndex != RoleType.image.index)
        .map((t) => _toTalkModel(entity: t))
        .toList();
  }

  ///
  /// スレッドに対応する会話情報を形式にかかわらず全て取得する
  ///
  Future<List<Talk>> findAllTalks(int threadId) async {
    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);
    if (talkBox.isEmpty) {
      return [];
    }

    return talkBox.values //
        .where((t) => t.threadId == threadId)
        .map((t) => (t.roleTypeIndex == RoleType.image.index) ? _toImageTalkModel(entity: t) : _toTalkModel(entity: t))
        .toList();
  }

  ///
  /// ユーザーとアシストの2つ分の会話を保存する
  ///
  Future<void> save({required int threadId, required String message, required Message talk, required int currentTotalTokens}) async {
    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);

    final newUserTalkId = await _ref.read(idDaoProvider).generate();
    await talkBox.put(newUserTalkId, _toEntityForUserTalk(id: newUserTalkId, threadId: threadId, message: message));

    final newAssistTalkId = await _ref.read(idDaoProvider).generate();
    await talkBox.put(newAssistTalkId, _toEntityForAssistTalk(id: newAssistTalkId, threadId: threadId, talk: talk));

    // スレッドの総トークン数を更新
    final threadBox = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);

    // このタイミングでThreadIDのスレッドは絶対存在するため!をつける
    final updateThread = threadBox.get(threadId)!.updateTokenNum(currentTotalTokens);
    await threadBox.put(threadId, updateThread);
  }

  ///
  /// 画像生成の会話を保存する
  ///
  Future<void> saveImageTalk({required int threadId, required String message, required List<String> iamgeUrls}) async {
    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);

    final newUserTalkId = await _ref.read(idDaoProvider).generate();
    await talkBox.put(newUserTalkId, _toEntityForUserTalk(id: newUserTalkId, threadId: threadId, message: message));

    final newImageTalkId = await _ref.read(idDaoProvider).generate();
    await talkBox.put(newImageTalkId, _toEntityForImageTalk(id: newImageTalkId, threadId: threadId, imageUrls: iamgeUrls));
  }

  ///
  /// 会話を削除する
  ///
  Future<void> delete({required int threadId}) async {
    // スレッドを削除
    final threadBox = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);
    await threadBox.delete(threadId);

    // 会話を削除
    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);
    final targetTalks = talkBox.values.where((t) => t.threadId == threadId).map((t) => t.id);
    await talkBox.deleteAll(targetTalks);
  }

  ///
  /// スレッドタイトルと会話メッセージに対し、引数の文字列を部分一致検索してマッチしたスレッドIDをリスト形式で取得する。
  /// なお、スレッドIDは重複して返さない。
  ///
  Future<List<int>> findThreadIDsByKeywordInTalkMessage(String searchWord) async {
    final threadBox = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);
    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);
    if (threadBox.isEmpty || talkBox.isEmpty) {
      return [];
    }

    final idsByThreadTitle = threadBox.values.where((t) => t.title.contains(searchWord)).map((t) => t.id);
    final idsByTalkMessage = talkBox.values.where((t) => t.message.contains(searchWord)).map((t) => t.threadId);
    final idsMergeAndDistinct = [...idsByThreadTitle, ...idsByTalkMessage]..toSet();

    return idsMergeAndDistinct.toList();
  }

  // ここから下はModelクラスとEntityの変換関数

  TalkEntity _toEntityForUserTalk({required int id, required int threadId, required String message}) {
    return TalkEntity(
      id: id,
      threadId: threadId,
      roleTypeIndex: RoleType.user.index,
      message: message,
      totalTokenNum: 0,
    );
  }

  TalkEntity _toEntityForAssistTalk({required int id, required int threadId, required Message talk}) {
    return TalkEntity(
      id: id,
      threadId: threadId,
      roleTypeIndex: RoleType.assistant.index,
      message: talk.getValue(),
      totalTokenNum: talk.tokenNum,
    );
  }

  TalkEntity _toEntityForImageTalk({required int id, required int threadId, required List<String> imageUrls}) {
    return TalkEntity(
      id: id,
      threadId: threadId,
      roleTypeIndex: RoleType.image.index,
      message: imageUrls.join(ImageTalk.urlJoinStringSeparate),
      totalTokenNum: 0, // imageの場合は0
    );
  }

  Message _toTalkModel({required TalkEntity entity}) {
    return Message.create(
      roleType: Talk.toRole(entity.roleTypeIndex),
      value: entity.message,
      tokenNum: entity.totalTokenNum,
    );
  }

  ImageTalk _toImageTalkModel({required TalkEntity entity}) {
    return ImageTalk.create(
      urls: entity.message.split(ImageTalk.urlJoinStringSeparate),
    );
  }

  TalkThread _toThreadModel(TalkThreadEntity entity) {
    return TalkThread.create(
      id: entity.id,
      title: entity.title,
      llmModel: LlmModel.toModel(entity.llmModelName),
      createAt: entity.createAt,
      totalUseTokens: entity.totalTalkTokenNum,
    );
  }
}
