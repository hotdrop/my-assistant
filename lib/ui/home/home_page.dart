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
    final maxTokenNum = ref.watch(appSettingsProvider.select((value) => value.maxTokenNum));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        Text('このスレッドのトークン利用数: $totalTokenNum/$maxTokenNum'),
        const SizedBox(width: 8),
        Tooltip(
          message: '最大トークン数は$maxTokenNumです。最大トークンに達したら会話続行はできません。',
          child: LineIcon(LineIcons.questionCircle),
        )
      ]),
    );
  }
}

class _ViewInputTalk extends ConsumerWidget {
  const _ViewInputTalk();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isError = ref.watch(errorProvider) != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ref.watch(talkControllerProvider),
              minLines: 1,
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          RawMaterialButton(
            onPressed: isError ? null : () => ref.read(homeControllerProvider.notifier).postTalk(),
            padding: const EdgeInsets.all(8),
            fillColor: Colors.blue,
            shape: const CircleBorder(),
            child: LineIcon(LineIcons.paperPlane, size: 28),
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
          child: Text('内容をクリアしてスレッドを新規作成する'),
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
