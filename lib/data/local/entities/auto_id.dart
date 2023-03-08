import 'package:hive_flutter/hive_flutter.dart';

part 'auto_id.g.dart';

@HiveType(typeId: 3)
class AutoId extends HiveObject {
  AutoId({required this.id});

  static const String boxName = 'autoId';

  @HiveField(0)
  final int id;
}
