import 'package:assistant_me/model/app_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final authenticationProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(Duration.zero);
  // TODO ここ本当は認証する
  final email = 'dummy@dummy.jp';
  ref.read(appSettingsProvider.notifier).setEmail(email);
});
