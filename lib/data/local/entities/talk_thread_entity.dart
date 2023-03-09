import 'package:hive_flutter/hive_flutter.dart';

part 'talk_thread_entity.g.dart';

@HiveType(typeId: 1)
class TalkThreadEntity extends HiveObject {
  TalkThreadEntity({
    required this.id,
    required this.title,
    required this.createAt,
    this.deleteAt,
    required this.totalTalkTokenNum,
  });

  static const String boxName = 'talkthread';

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createAt;

  @HiveField(3)
  final DateTime? deleteAt;

  // 会話の総トークン数は会話のリストから取得すればいいのだが、会話は物理削除してしまうのでスレッドで総トークン数を持っている
  @HiveField(4)
  final int totalTalkTokenNum;

  TalkThreadEntity updateTokenNum(int addTokenNum) {
    return TalkThreadEntity(
      id: id,
      title: title,
      createAt: createAt,
      deleteAt: deleteAt,
      totalTalkTokenNum: totalTalkTokenNum + addTokenNum,
    );
  }

  TalkThreadEntity toDelete() {
    return TalkThreadEntity(
      id: id,
      title: title,
      createAt: createAt,
      deleteAt: DateTime.now(),
      totalTalkTokenNum: totalTalkTokenNum,
    );
  }
}
