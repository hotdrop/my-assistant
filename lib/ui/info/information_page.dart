import 'package:assistant_me/model/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

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
            SizedBox(height: 8),
            _ViewInputApiKey(),
            SizedBox(height: 16),
            Text('ここにAPIのsystemに設定する文字列を表示する'),
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
              width: 500,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('API Keyをここに入力してください'),
                  counterText: '',
                ),
                maxLength: 50,
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
