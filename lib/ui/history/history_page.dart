import 'package:assistant_me/ui/history/history_card.dart';
import 'package:assistant_me/ui/history/history_controller.dart';
import 'package:assistant_me/ui/widgets/assistant_chat_row_widget.dart';
import 'package:assistant_me/ui/widgets/user_chat_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      return const _ViewBodyNonHistory();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(flex: 3, child: _ViewBodyHistories()),
          Expanded(flex: 7, child: _ViewBodyHistoryTalks()),
        ],
      ),
    );
  }
}

class _ViewBodyNonHistory extends StatelessWidget {
  const _ViewBodyNonHistory();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('履歴はありません。'),
    );
  }
}

class _ViewBodyHistories extends ConsumerWidget {
  const _ViewBodyHistories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(historyThreadsStateProvider);
    final selectedThreadId = ref.watch(historySelectedThreadIdProvider);

    return SingleChildScrollView(
      child: Wrap(
        verticalDirection: VerticalDirection.down,
        children: threads.map((t) {
          return ViewHistoryCard(
            thread: t,
            isSelected: selectedThreadId == t.id,
            onTap: (int threadId) {
              ref.read(historyControllerProvider.notifier).onLoad(threadId);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ViewBodyHistoryTalks extends ConsumerWidget {
  const _ViewBodyHistoryTalks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talks = ref.watch(historyTalksStateProvider);

    return CustomScrollView(
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
