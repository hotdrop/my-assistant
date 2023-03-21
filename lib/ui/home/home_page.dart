import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/model/template.dart';
import 'package:assistant_me/ui/home/home_controller.dart';
import 'package:assistant_me/ui/widgets/assistant_chat_row_widget.dart';
import 'package:assistant_me/ui/widgets/user_chat_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム画面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _ViewHeader(),
            SizedBox(height: 8),
            _ViewTemplate(),
            SizedBox(height: 8),
            _ViewInputTalk(),
            _ViewErrorLabel(),
            SizedBox(height: 8),
            _ViewNewThreadButton(),
            Divider(),
            Flexible(
              child: _ViewTalkArea(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewHeader extends ConsumerWidget {
  const _ViewHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      'この会話のトークン数: ${ref.watch(threadProvider.select((value) => value.currentTalkNum))}',
    );
  }
}

class _ViewTemplate extends ConsumerWidget {
  const _ViewTemplate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templateNotifierProvider);
    const double widgetWidth = 300;

    if (templates.isEmpty) {
      return Container(
        width: widgetWidth,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: Border.all(width: 1, color: Colors.grey),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('テンプレートは登録されていません', style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    return SizedBox(
      width: widgetWidth,
      child: ExpansionTile(
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: BorderSide(width: 1, color: Colors.grey),
        ),
        title: Row(
          children: [
            LineIcon(LineIcons.alternateFileAlt),
            const SizedBox(width: 8),
            Text('テンプレートを使う', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: templates.map((t) => _RowTemplate(t, width: widgetWidth)).toList(),
      ),
    );
  }
}

class _RowTemplate extends ConsumerWidget {
  const _RowTemplate(this.template, {required this.width});

  final Template template;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: width,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(template.title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        onTap: () {
          ref.read(homeControllerProvider.notifier).setTemplate(template.contents);
        },
      ),
    );
  }
}

class _ViewInputTalk extends ConsumerWidget {
  const _ViewInputTalk();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cannotTalk = ref.watch(appSettingsProvider).apiKey?.isEmpty ?? true;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: ref.watch(talkControllerProvider),
            minLines: 1,
            maxLines: 10,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
        RawMaterialButton(
          onPressed: cannotTalk ? null : () => ref.read(homeControllerProvider.notifier).postTalk(),
          padding: const EdgeInsets.all(8),
          fillColor: AppTheme.primaryColor,
          shape: const CircleBorder(),
          child: LineIcon(LineIcons.paperPlane, size: 28, color: Colors.white),
        ),
      ],
    );
  }
}

class _ViewErrorLabel extends ConsumerWidget {
  const _ViewErrorLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMsg = ref.watch(errorProvider);
    if (errorMsg == null) {
      return const SizedBox();
    }

    return Center(
      child: Text(
        errorMsg,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _ViewNewThreadButton extends ConsumerWidget {
  const _ViewNewThreadButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: OutlinedButton(
        onPressed: () {
          ref.read(homeControllerProvider.notifier).newThread();
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text('新しく会話を始める'),
        ),
      ),
    );
  }
}

class _ViewTalkArea extends ConsumerWidget {
  const _ViewTalkArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talks = ref.watch(currentTalksProvider);

    return CustomScrollView(
      controller: ref.watch(chatScrollControllerProvider),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final isUser = talks[index].isRoleTypeUser();
              if (isUser) {
                return UserChatRowWidget(talk: talks[index]);
              } else {
                return AssistantChatRowWidget(talk: talks[index]);
              }
            },
            childCount: talks.length,
          ),
        ),
      ],
    );
  }
}
