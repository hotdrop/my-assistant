import 'package:hive_flutter/hive_flutter.dart';

part 'template_entity.g.dart';

@HiveType(typeId: 4)
class TemplateEntity extends HiveObject {
  TemplateEntity({
    required this.id,
    required this.title,
    required this.contents,
  });

  static const String boxName = 'template';

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String contents;

  TemplateEntity copyWith({String? title, String? contents}) {
    return TemplateEntity(
      id: id,
      title: title ?? this.title,
      contents: contents ?? this.contents,
    );
  }
}
