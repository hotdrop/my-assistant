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
    required this.currentTokenNum,
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

  @HiveField(4)
  final int totalTalkTokenNum;

  @HiveField(5, defaultValue: 0)
  final int currentTokenNum;

  TalkThreadEntity updateTokenNum(int tokenNum) {
    return TalkThreadEntity(
      id: id,
      title: title,
      createAt: createAt,
      deleteAt: deleteAt,
      totalTalkTokenNum: totalTalkTokenNum + tokenNum,
      currentTokenNum: tokenNum,
    );
  }

  TalkThreadEntity toDelete() {
    return TalkThreadEntity(
      id: id,
      title: title,
      createAt: createAt,
      deleteAt: DateTime.now(),
      totalTalkTokenNum: totalTalkTokenNum,
      currentTokenNum: currentTokenNum,
    );
  }
}
