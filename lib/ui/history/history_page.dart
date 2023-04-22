import 'package:assistant_me/common/app_extension.dart';
import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/ui/history/history_card.dart';
import 'package:assistant_me/ui/history/history_controller.dart';
import 'package:assistant_me/ui/widgets/app_text.dart';
import 'package:assistant_me/ui/widgets/assistant_chat_row_widget.dart';
import 'package:assistant_me/ui/widgets/image_chat_row_widget.dart';
import 'package:assistant_me/ui/widgets/user_chat_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.pageTitle('履歴'),
      ),
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
        child: AppText.error(errorMessage!),
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
          _ViewThreadCreateDate(),
          _ViewThreadUsageToken(),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppText.normal('履歴はありません。'),
    );
  }
}

class _ViewThreadCreateDate extends ConsumerWidget {
  const _ViewThreadCreateDate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThread = ref.watch(historySelectedThreadProvider);
    if (currentThread == null) {
      return const SizedBox();
    }
    return Center(
      child: AppText.normal(
        currentThread.toDateTimeString(),
        textColor: AppTheme.primaryColor,
      ),
    );
  }
}

class _ViewThreadUsageToken extends ConsumerWidget {
  const _ViewThreadUsageToken();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThread = ref.watch(historySelectedThreadProvider);
    if (currentThread == null) {
      return const SizedBox();
    }
    return Center(
      child: AppText.small('(このスレッドの総消費トークン数: ${currentThread.totalUseTokens.toCommaFormat()})'),
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
        children: threads
            .map((t) => ViewHistoryCard(
                  thread: t,
                  isSelected: selectedThreadId == t.id,
                  onTap: (int threadId) => ref.read(historyControllerProvider.notifier).onLoad(threadId),
                  onDelete: (int threadId) {
                    ref.read(historyControllerProvider.notifier).delete(threadId);
                  },
                ))
            .toList(),
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
              switch (talks[index].roleType) {
                case RoleType.user:
                  return UserChatRowWidget(talk: talks[index]);
                case RoleType.assistant:
                  return AssistantChatRowWidget(talk: talks[index]);
                case RoleType.image:
                  return ImageChatRowWidget(talk: talks[index]);
                default:
                  throw UnimplementedError('未実装のRoleTypeです。 index=${talks[index].roleType.index}');
              }
            },
            childCount: talks.length,
          ),
        ),
      ],
    );
  }
}
