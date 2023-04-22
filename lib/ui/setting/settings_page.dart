import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/ui/setting/setting_controller.dart';
import 'package:assistant_me/ui/widgets/app_text.dart';
import 'package:file_selector/file_selector.dart';
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
        title: AppText.pageTitle('設定情報'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.large('アプリ設定', isBold: true),
            const Divider(),
            const SizedBox(height: 16),
            const _ViewInputApiKey(),
            const SizedBox(height: 16),
            AppText.large('テンプレート', isBold: true),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                _ViewTemplateImportButton(),
                SizedBox(width: 16),
                _ViewTemplateExportButton(),
              ],
            ),
            AppText.normal('(※ 誤操作防止のため、インポートはテンプレートを全て削除すると実行可能になります)'),
            const _ViewTempleteMessage(),
            const SizedBox(height: 16),
            AppText.large('メモ', isBold: true),
            const Divider(),
            const _ViewMemoList(),
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
          LineIcon(LineIcons.key, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: SizedBox(
              width: 700,
              child: TextFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: AppText.normal('ここにOpen_API_Keyを入力してください'),
                  counterText: '',
                ),
                style: const TextStyle(fontSize: AppTheme.defaultTextSize),
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

class _ViewTemplateImportButton extends ConsumerWidget {
  const _ViewTemplateImportButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enable = ref.watch(templateCanImportProvider);
    return ElevatedButton.icon(
      onPressed: enable ? () async => await execImport(ref) : null,
      icon: LineIcon(LineIcons.fileImport),
      label: AppText.normal('インポート'),
    );
  }

  Future<void> execImport(WidgetRef ref) async {
    const fileTypeGroup = XTypeGroup(label: 'json', extensions: <String>['json']);
    final file = await openFile(acceptedTypeGroups: [fileTypeGroup]);
    if (file != null) {
      final rawData = await file.readAsString();
      await ref.read(settingControllerProvider.notifier).importTemplate(rawData);
    }
  }
}

class _ViewTemplateExportButton extends ConsumerWidget {
  const _ViewTemplateExportButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enable = ref.watch(templateCanExportProvider);
    return ElevatedButton.icon(
      onPressed: enable ? () => execExport(context, ref) : null,
      icon: LineIcon(LineIcons.fileExport),
      label: AppText.normal('エクスポート'),
    );
  }

  void execExport(BuildContext context, WidgetRef ref) {
    ref.read(settingControllerProvider.notifier).exportTemplate();
  }
}

class _ViewTempleteMessage extends ConsumerWidget {
  const _ViewTempleteMessage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(templateMessageStateProvider);
    return AppText.normal(message ?? '', textColor: AppTheme.primaryColor);
  }
}

class _ViewMemoList extends StatelessWidget {
  const _ViewMemoList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.normal('・履歴を削除したい場合、カード右上のバツボタンを長押ししてください。'),
        AppText.normal('・アシスタント側の回答はアイコンをクリックするとコピーできます。'),
        AppText.normal('・よく使いそうなPromptや面白いPromptを見つけたらテンプレートに登録しましょう。'),
        AppText.normal('・こまめに以下のページで使用料を確認しましょう。', textColor: AppTheme.primaryColor),
        const _ViewUsageFeeLink(),
      ],
    );
  }
}

class _ViewUsageFeeLink extends StatelessWidget {
  const _ViewUsageFeeLink();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AppText.weblink('https://platform.openai.com/account/usage'),
      ),
      onTap: () async => launchUrl(Uri.parse('https://platform.openai.com/account/usage')),
    );
  }
}
