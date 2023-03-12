import 'package:assistant_me/model/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定情報'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('【メモ】'),
            Text('・履歴を削除したい場合、カード右上のバツボタンを長押ししてください。'),
            SizedBox(height: 16),
            _ViewInputApiKey(),
          ],
        ),
      ),
    );
  }
}

class _ViewInputApiKey extends ConsumerWidget {
  const _ViewInputApiKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LineIcon(LineIcons.key, size: 32),
          const SizedBox(width: 8),
          Flexible(
            child: SizedBox(
              width: 700,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('ここにGhatGPT API Keyを入力してください'),
                  counterText: '',
                ),
                initialValue: ref.watch(appSettingsProvider).apiKey,
                maxLength: 100,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(appSettingsProvider.notifier).setApiKey(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
