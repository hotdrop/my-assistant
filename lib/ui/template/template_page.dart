import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/template.dart';
import 'package:assistant_me/ui/template/template_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TemplatePage extends ConsumerWidget {
  const TemplatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テンプレート'),
      ),
      body: ref.watch(templateControllerProvider).when(
            data: (_) => const _ViewBody(),
            error: (error, stackTrace) => _ViewOnLoading(errorMessage: '$error'),
            loading: () => const _ViewOnLoading(),
          ),
    );
  }
}

class _ViewOnLoading extends StatelessWidget {
  const _ViewOnLoading({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(color: Theme.of(context).primaryColor, size: 32),
    );
  }
}

class _ViewBody extends StatelessWidget {
  const _ViewBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ここでは会話に使用するテンプレートを管理することができます。'),
          const SizedBox(height: 16),
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Flexible(flex: 1, child: _ViewListArea()),
                Flexible(flex: 2, child: _ViewEditArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewListArea extends ConsumerWidget {
  const _ViewListArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesStateProvider);
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
          child: Text(template.title, overflow: TextOverflow.ellipsis),
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
      label: Text(isUpdate ? '更新する' : '登録する'),
    );
  }
}
