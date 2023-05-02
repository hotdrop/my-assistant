import 'package:assistant_me/model/llm_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'talk_thread_entity.g.dart';

@HiveType(typeId: 1)
class TalkThreadEntity extends HiveObject {
  TalkThreadEntity({
    required this.id,
    required this.title,
    required this.system,
    required this.createAt,
    required this.totalTalkTokenNum,
    required this.currentTokenNum,
    required this.llmModelName,
  });

  static const String boxName = 'talkthread';

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createAt;

  @HiveField(4)
  final int totalTalkTokenNum;

  @HiveField(5, defaultValue: 0)
  final int currentTokenNum;

  @HiveField(6, defaultValue: LlmModel.gpt3ModelName)
  final String llmModelName;

  @HiveField(8, defaultValue: '')
  final String? system;

  TalkThreadEntity copyWith({int? tokenNum, String? system}) {
    return TalkThreadEntity(
      id: id,
      title: title,
      system: system ?? this.system,
      createAt: createAt,
      totalTalkTokenNum: (tokenNum != null) ? totalTalkTokenNum + tokenNum : totalTalkTokenNum,
      currentTokenNum: tokenNum ?? currentTokenNum,
      llmModelName: llmModelName,
    );
  }
}
