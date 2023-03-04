import 'package:assistant_me/model/account.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final authenticationProvider = FutureProvider<Account>((_) async {
  await Future<void>.delayed(Duration.zero);
  // TODO ここ本当は認証する
  final user = Account(email: 'dummy@dummy.jp');

  return user;
});
