import 'package:assistant_me/ui/home/home_controller.dart';
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
        children: [
          const _ViewHeader(),
          const _ViewInputTalk(),
          const _ViewErrorLabel(),
          const Divider(),
          // チャット欄
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
      child: Row(
        children: [
          Text('このスレッドのトークン利用数: $totalTokenNum'),
        ],
      ),
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
