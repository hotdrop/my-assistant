import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

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
            Text('アプリ設定', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Divider(),
            SizedBox(height: 16),
            _ViewInputApiKey(),
            SizedBox(height: 16),
            Text('メモ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Divider(),
            SizedBox(height: 16),
            _ViewMemoList(),
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

class _ViewMemoList extends StatelessWidget {
  const _ViewMemoList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('・履歴を削除したい場合、カード右上のバツボタンを長押ししてください。'),
        Text('・アシスタント側の回答はアイコンをクリックするとコピーできます。'),
        Text('・よく使いそうなPromptや面白いPromptを見つけたらテンプレートに登録しましょう。'),
        Text('・こまめに以下のページで使用料を確認しましょう。', style: TextStyle(color: AppTheme.primaryColor)),
        _ViewUsageFeeLink(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _ViewUsageFeeLink extends StatelessWidget {
  const _ViewUsageFeeLink();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text('https://platform.openai.com/account/usage', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
      ),
      onTap: () async => launchUrl(Uri.parse('https://platform.openai.com/account/usage')),
    );
  }
}
