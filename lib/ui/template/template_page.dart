import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/template.dart';
import 'package:assistant_me/ui/template/template_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class TemplatePage extends ConsumerWidget {
  const TemplatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テンプレート'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Flexible(flex: 1, child: _ViewListArea()),
            Flexible(flex: 2, child: _ViewEditArea()),
          ],
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
      return const Text('テンプレートは未登録です。タイトルとテンプレート内容を入力して登録しましょう！');
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
              Flexible(child: Text(template.title, overflow: TextOverflow.ellipsis)),
              InkWell(
                child: LineIcon(LineIcons.times, color: Colors.grey),
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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text('タイトル'),
            ),
            controller: ref.watch(titleControllerStateProvider),
            maxLength: 50,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('テンプレート内容'),
              ),
              controller: ref.watch(contentsControllerStateProvider),
              maxLines: 20,
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
      icon: LineIcon(LineIcons.save),
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(isUpdate ? '更新する' : '登録する'),
      ),
    );
  }
}
