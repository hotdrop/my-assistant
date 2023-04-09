import 'package:assistant_me/model/llm_model.dart';
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
    required this.llmModelName,
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

  // HiveField(5)は現在の消費トークン数を保持していたがストレージに保持する必要性がなかったためリファクタで除去した

  @HiveField(6, defaultValue: LlmModel.gpt3ModelName)
  final String llmModelName;

  TalkThreadEntity updateTokenNum(int tokenNum) {
    return TalkThreadEntity(
      id: id,
      title: title,
      createAt: createAt,
      deleteAt: deleteAt,
      totalTalkTokenNum: totalTalkTokenNum + tokenNum,
      llmModelName: llmModelName,
    );
  }

  TalkThreadEntity toDelete() {
    return TalkThreadEntity(
      id: id,
      title: title,
      createAt: createAt,
      deleteAt: DateTime.now(),
      totalTalkTokenNum: totalTalkTokenNum,
      llmModelName: llmModelName,
    );
  }
}
