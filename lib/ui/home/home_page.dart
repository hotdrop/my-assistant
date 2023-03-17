import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/app_settings.dart';
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
      body: Column(
        children: const [
          _ViewHeader(),
          _ViewInputTalk(),
          _ViewErrorLabel(),
          _ViewNewThreadButton(),
          Divider(),
          Flexible(
            child: _ViewTalkArea(),
          ),
        ],
      ),
    );
  }
}

class _ViewHeader extends ConsumerWidget {
  const _ViewHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTokenNum = ref.watch(totalTokenNumProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        Text('この会話のトークン利用数: $totalTokenNum'),
        const SizedBox(width: 8),
      ]),
    );
  }
}

class _ViewInputTalk extends ConsumerWidget {
  const _ViewInputTalk();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cannotTalk = ref.watch(appSettingsProvider).apiKey?.isEmpty ?? true;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: ref.watch(talkControllerProvider),
              minLines: 1,
              maxLines: 5,
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
      ),
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

    return Text(errorMsg, style: const TextStyle(color: Colors.red));
  }
}

class _ViewNewThreadButton extends ConsumerWidget {
  const _ViewNewThreadButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        onPressed: () {
          ref.read(homeControllerProvider.notifier).newThread();
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
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
      ),
    );
  }
}
