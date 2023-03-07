import 'package:assistant_me/data/local/entities/talk_entity.dart';
import 'package:assistant_me/data/local/entities/talk_thread_entity.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final talkDaoProvider = Provider((_) => TalkDao());

class TalkDao {
  ///
  /// スレッドを新規生成する
  ///
  Future<TalkThread> createThread(String message) async {
    final box = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);
    final title = message.length < 30 ? message : message.substring(0, 30);

    final threadId = (box.isEmpty) ? 1 : box.length + 1;
    final talkThread = TalkThreadEntity(id: threadId, title: title, totalTalkTokenNum: 0);
    box.put(threadId, talkThread);

    return _toThreadModel(entity: talkThread, talkNum: 0, totalTalkTokenNum: 0);
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
      );
      results.add(talkThread);
    }
    return results;
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
        .map((t) => _toTalkModel(t))
        .toList();
  }

  ///
  /// ユーザーとアシストの2つ分の会話を保存する
  ///
  Future<void> save({required int threadId, required String message, required Talk talk}) async {
    final box = await Hive.openBox<TalkEntity>(TalkEntity.boxName);
    await box.add(_toEntityForUserTalk(threadId, message));
    await box.add(_toEntityForAssistTalk(threadId, talk));

    // スレッドの総トークン数を更新
    final threadBox = await Hive.openBox<TalkThreadEntity>(TalkThreadEntity.boxName);
    // このタイミングでThreadIDでは絶対ヒットするので!をつける
    final updateThread = threadBox.get(threadId)!.updateTokenNum(talk.totalTokenNum);
    threadBox.put(threadId, updateThread);
  }

  Future<void> delete({required int threadId}) async {
    // TODO 会話を削除
    // TODO スレッドの削除日付を設定
  }

  TalkEntity _toEntityForUserTalk(int threadId, String message) {
    return TalkEntity(
      threadId: threadId,
      dateTime: DateTime.now(),
      roleTypeIndex: RoleType.user.index,
      message: message,
      totalTokenNum: 0,
    );
  }

  TalkEntity _toEntityForAssistTalk(int threadId, Talk talk) {
    return TalkEntity(
      threadId: threadId,
      dateTime: talk.dateTime,
      roleTypeIndex: talk.roleType.index,
      message: talk.message,
      totalTokenNum: talk.totalTokenNum,
    );
  }

  Talk _toTalkModel(TalkEntity entity) {
    return Talk(
      dateTime: entity.dateTime,
      roleType: Talk.toRole(entity.roleTypeIndex),
      message: entity.message,
      totalTokenNum: entity.totalTokenNum,
    );
  }

  TalkThread _toThreadModel({required TalkThreadEntity entity, required int talkNum, required int totalTalkTokenNum, DateTime? deleteAt}) {
    return TalkThread(
      id: entity.id,
      title: entity.title,
      talkNum: talkNum,
      deleteAt: deleteAt,
      totalTalkTokenNum: totalTalkTokenNum,
    );
  }
}
