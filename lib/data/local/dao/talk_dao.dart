import 'package:assistant_me/data/local/dao/id_dao.dart';
import 'package:assistant_me/data/local/entities/talk_entity.dart';
import 'package:assistant_me/data/local/entities/talk_thread_entity.dart';
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
  Future<TalkThread> createThread(String message) async {
    final box = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);

    // スレッドに表示するタイトルは一旦最初の会話の先頭30文字としている。タイトルは変更できるようにした方がよさそう
    final title = message.length < 30 ? message : message.substring(0, 30);

    final newThreadId = await _ref.read(idDaoProvider).generate();
    final talkThread = TalkThreadEntity(
      id: newThreadId,
      createAt: DateTime.now(),
      title: title,
      totalTalkTokenNum: 0,
      currentTokenNum: 0,
    );
    box.put(newThreadId, talkThread);

    return _toThreadModel(entity: talkThread, talkNum: 0, totalTalkTokenNum: 0, currentTokenNum: 0);
  }

  ///
  /// 登録されているスレッドを取得する
  ///
  Future<TalkThread> findThread(int id) async {
    final box = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);
    final threadEntity = box.values.where((e) => e.id == id).first;

    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);
    final talkNum = talkBox.values.where((e) => e.threadId == id).length;

    return _toThreadModel(
      entity: threadEntity,
      talkNum: talkNum,
      deleteAt: threadEntity.deleteAt,
      totalTalkTokenNum: threadEntity.totalTalkTokenNum,
      currentTokenNum: threadEntity.currentTokenNum,
    );
  }

  ///
  /// 登録されているスレッドを全て取得する
  ///
  Future<List<TalkThread>> findAllThread() async {
    final box = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);
    if (box.isEmpty) {
      return [];
    }
    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);

    final results = <TalkThread>[];
    for (var thread in box.values) {
      final talks = talkBox.values.where((e) => e.threadId == thread.id);
      final talkThread = _toThreadModel(
        entity: thread,
        talkNum: talks.length,
        deleteAt: thread.deleteAt,
        totalTalkTokenNum: thread.totalTalkTokenNum,
        currentTokenNum: thread.currentTokenNum,
      );
      results.add(talkThread);
    }
    return results;
  }

  ///
  /// 指定した範囲内のスレッドを全て取得する
  /// スレッドが持っているトーク数は使用しない想定で0を設定しているので注意
  ///
  Future<List<TalkThread>> findRangeThread({required DateTime from, required DateTime to}) async {
    final box = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);
    if (box.isEmpty) {
      return [];
    }

    return box.values //
        .where((t) => t.createAt.isAfter(from) && t.createAt.isBefore(to))
        .map((t) => _toThreadModel(
              entity: t,
              talkNum: 0,
              deleteAt: t.deleteAt,
              totalTalkTokenNum: t.totalTalkTokenNum,
              currentTokenNum: t.currentTokenNum,
            ))
        .toList();
  }

  ///
  /// スレッドに対応する会話情報をリスト形式で全て取得する
  ///
  Future<List<Talk>> findTalks(int threadId) async {
    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);
    if (talkBox.isEmpty) {
      return [];
    }

    return talkBox.values //
        .where((t) => t.threadId == threadId)
        .map((t) => _toTalkModel(entity: t))
        .toList();
  }

  ///
  /// ユーザーとアシストの2つ分の会話を保存する
  ///
  Future<void> save({required int threadId, required String message, required Talk talk, required int currentTotalTokens}) async {
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
  /// 会話を削除する
  /// スレッドも削除してしまうと消費トークン数がわからなくなるので会話のみ削除している
  ///
  Future<void> delete({required int threadId}) async {
    final threadBox = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);

    // スレッドは削除状態にするのみ
    // このタイミングでThreadIDのスレッドは絶対存在するため!をつける
    final deleteThread = threadBox.get(threadId)!.toDelete();
    await threadBox.put(threadId, deleteThread);

    // 会話を削除
    final talkBox = await Hive.openBox<TalkEntity>(TalkEntity.boxName);
    final targetTalks = talkBox.values.where((t) => t.threadId == threadId).map((t) => t.id);
    await talkBox.deleteAll(targetTalks);
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

  TalkEntity _toEntityForAssistTalk({required int id, required int threadId, required Talk talk}) {
    return TalkEntity(
      id: id,
      threadId: threadId,
      roleTypeIndex: talk.roleType.index,
      message: talk.message,
      totalTokenNum: talk.tokenNum,
    );
  }

  Talk _toTalkModel({required TalkEntity entity}) {
    return Talk(
      roleType: Talk.toRole(entity.roleTypeIndex),
      message: entity.message,
      tokenNum: entity.totalTokenNum,
    );
  }

  TalkThread _toThreadModel({
    required TalkThreadEntity entity,
    required int talkNum,
    required int totalTalkTokenNum,
    required int currentTokenNum,
    DateTime? deleteAt,
  }) {
    return TalkThread(
      id: entity.id,
      title: entity.title,
      createAt: entity.createAt,
      talkNum: talkNum,
      deleteAt: deleteAt,
      totalTalkTokenNum: totalTalkTokenNum,
      currentTalkNum: currentTokenNum,
    );
  }
}
