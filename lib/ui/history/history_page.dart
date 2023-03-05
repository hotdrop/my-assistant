import 'package:assistant_me/model/talk_thread.dart';
import 'package:assistant_me/ui/history/detail/history_detail_page.dart';
import 'package:assistant_me/ui/history/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('履歴')),
      body: ref.watch(historyControllerProvider).when(
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

class _ViewBody extends ConsumerWidget {
  const _ViewBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(historyThreadsStateProvider);
    if (threads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('履歴はありません。'),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        children: threads.map((e) => _ViewHistoryCard(thread: e)).toList(),
      ),
    );
  }
}

class _ViewHistoryCard extends StatelessWidget {
  const _ViewHistoryCard({required this.thread});

  final TalkThread thread;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 100,
      child: Card(
        elevation: 4,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(thread.title),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('スレッドID: ${thread.id}', style: Theme.of(context).textTheme.bodySmall),
                    _ViewRowTalks(talkNum: thread.talkNum),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            HistoryDetailPage.start(context, thread.id);
          },
        ),
      ),
    );
  }
}

class _ViewRowTalks extends StatelessWidget {
  const _ViewRowTalks({required this.talkNum});

  final int talkNum;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LineIcon(LineIcons.comment),
        const SizedBox(width: 4),
        Text(talkNum.toString()),
      ],
    );
  }
}
