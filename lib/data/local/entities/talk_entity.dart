import 'package:hive_flutter/hive_flutter.dart';

part 'talk_entity.g.dart';

@HiveType(typeId: 2)
class TalkEntity extends HiveObject {
  TalkEntity({
    required this.threadId,
    required this.dateTime,
    required this.roleTypeIndex,
    required this.message,
    required this.totalTokenNum,
  });

  static const String boxName = 'talk';

  @HiveField(0)
  final int threadId;

  @HiveField(1)
  final DateTime dateTime;

  @HiveField(2)
  final int roleTypeIndex;

  @HiveField(3)
  final String message;

  @HiveField(4)
  final int totalTokenNum;
}
