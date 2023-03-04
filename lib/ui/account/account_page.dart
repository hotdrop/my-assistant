import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アカウント情報'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const _ViewAccountInfo(),
          const _ViewInputApiKey(),
        ]),
      ),
    );
  }
}

class _ViewAccountInfo extends ConsumerWidget {
  const _ViewAccountInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = 'test@dummy.jp';
    return Column(
      children: [
        Text('ログイン中のアカウント情報'),
        Text('メールアドレス: $email'),
      ],
    );
  }
}

class _ViewInputApiKey extends ConsumerWidget {
  const _ViewInputApiKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        label: Text('ChatGPT API Keyを登録してください。'),
      ),
      maxLines: 1,
      maxLength: 100,
    );
  }
}
