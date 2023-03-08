import 'package:assistant_me/data/local/entities/auto_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final idDaoProvider = Provider((_) => _IDDao());

class _IDDao {
  static const int _key = 1;
  static const int _firstId = 1;

  Future<int> generate() async {
    final box = await Hive.openBox<AutoId>(AutoId.boxName);
    if (box.isEmpty) {
      box.put(_key, AutoId(id: _firstId));
      return _firstId;
    }

    final currentId = box.get(_key)?.id ?? _firstId;
    final nextId = currentId + 1;
    box.put(_key, AutoId(id: nextId));
    return nextId;
  }
}
