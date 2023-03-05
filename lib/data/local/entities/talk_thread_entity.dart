import 'package:hive_flutter/hive_flutter.dart';

part 'talk_thread_entity.g.dart';

@HiveType(typeId: 1)
class TalkThreadEntity extends HiveObject {
  TalkThreadEntity({
    required this.id,
    required this.title,
  });
  static const String boxName = 'talkthread';

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;
}
