import 'package:assistant_me/data/local/entities/auto_id.dart';
import 'package:assistant_me/data/local/entities/talk_entity.dart';
import 'package:assistant_me/data/local/entities/talk_thread_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final localDataSourceProvider = Provider((ref) => const _LocalDataSource());

class _LocalDataSource {
  const _LocalDataSource();

  ///
  /// アプリ起動時に必ず呼ぶ
  ///
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TalkEntityAdapter());
    Hive.registerAdapter(TalkThreadEntityAdapter());
    Hive.registerAdapter(AutoIdAdapter());
  }
}
