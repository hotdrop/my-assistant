import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/template.dart';
import 'package:assistant_me/ui/template/template_controller.dart';
import 'package:assistant_me/ui/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplatePage extends ConsumerWidget {
  const TemplatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      // 画面外をタップしたら選択クリア
      onTap: () => ref.read(templateControllerProvider.notifier).clear(),
      child: Scaffold(
        appBar: AppBar(
          title: AppText.pageTitle('テンプレート'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(flex: 1, child: _ViewListArea()),
              Flexible(flex: 2, child: _ViewEditArea()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewListArea extends ConsumerWidget {
  const _ViewListArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templateNotifierProvider);
    if (templates.isEmpty) {
      return AppText.normal('テンプレートは未登録です。タイトルとテンプレート内容を入力して登録しましょう！');
    }

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            templates.map((e) => _RowList(e)).toList(),
          ),
        ),
      ],
    );
  }
}

class _RowList extends ConsumerWidget {
  const _RowList(this.template);

  final Template template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(selectTemplateIdStateProvider) == template.id;
    return Card(
      elevation: 0,
      color: isSelected ? AppTheme.selectedCardColor : null,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: AppText.normal(template.title, overflow: TextOverflow.ellipsis)),
              InkWell(
                child: const Icon(Icons.delete_forever, color: Colors.grey),
                onLongPress: () async => await ref.read(templateControllerProvider.notifier).deleteTemplate(template),
              ),
            ],
          ),
        ),
        onTap: () {
          ref.read(templateControllerProvider.notifier).select(template.id);
        },
      ),
    );
  }
}

class _ViewEditArea extends ConsumerWidget {
  const _ViewEditArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              label: AppText.normal('タイトル'),
            ),
            style: const TextStyle(fontSize: AppTheme.defaultTextSize),
            controller: ref.watch(titleControllerStateProvider),
            maxLength: 50,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: AppText.normal('テンプレート内容'),
              ),
              style: const TextStyle(fontSize: AppTheme.defaultTextSize),
              controller: ref.watch(contentsControllerStateProvider),
              maxLines: 30,
            ),
          ),
          const SizedBox(height: 16),
          const _ViewSaveButton(),
        ],
      ),
    );
  }
}

class _ViewSaveButton extends ConsumerWidget {
  const _ViewSaveButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdate = ref.watch(selectTemplateIdStateProvider) != TemplateController.unselecId;

    return ElevatedButton.icon(
      onPressed: () async {
        if (isUpdate) {
          await ref.read(templateControllerProvider.notifier).updateTemplate();
        } else {
          await ref.read(templateControllerProvider.notifier).createTemplate();
        }
      },
      icon: const Padding(
        padding: EdgeInsets.only(left: 24),
        child: Icon(Icons.save),
      ),
      label: Padding(
        padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12, right: 24),
        child: AppText.normal(isUpdate ? '更新する' : '登録する'),
      ),
    );
  }
}
