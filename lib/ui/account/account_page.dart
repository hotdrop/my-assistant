import 'package:assistant_me/model/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント情報'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _ViewEmail(),
            SizedBox(height: 8),
            _ViewInputApiKey(),
          ],
        ),
      ),
    );
  }
}

class _ViewEmail extends ConsumerWidget {
  const _ViewEmail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(appSettingsProvider).email ?? 'ー';
    return ListTile(
      leading: LineIcon(LineIcons.smilingFace, size: 32),
      title: const Text('ログイン中のメールアドレス'),
      subtitle: Text(email),
    );
  }
}

class _ViewInputApiKey extends ConsumerWidget {
  const _ViewInputApiKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          label: Text('ChatGPT API Keyをここに入力してください'),
        ),
        maxLength: 50,
        onChanged: (String? value) {
          if (value != null) {
            ref.read(appSettingsProvider.notifier).setApiKey(value);
          }
        },
      ),
    );
  }
}
