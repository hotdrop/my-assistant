import 'package:assistant_me/common/app_extension.dart';
import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:assistant_me/ui/history/history_card.dart';
import 'package:assistant_me/ui/history/history_controller.dart';
import 'package:assistant_me/ui/home/home_controller.dart';
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

class _ViewBody extends StatelessWidget {
  const _ViewBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ViewFilterArea(),
          _ViewBodyHistories(),
          _ViewHistoryTalkHeaderArea(),
          Expanded(flex: 7, child: _ViewBodyHistoryTalks()),
        ],
      ),
    );
  }
}

class _ViewFilterArea extends ConsumerWidget {
  const _ViewFilterArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(historyHeaderVisibleStateProvider),
      child: const Row(
        children: [
          _ViewSearchField(),
          SizedBox(width: 32),
          _ViewFilterSortIcon(),
          SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _ViewSearchField extends ConsumerWidget {
  const _ViewSearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: TextFormField(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(2),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.search),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
        ),
        style: const TextStyle(fontSize: AppTheme.defaultTextSize),
        onFieldSubmitted: (String? text) {
          ref.read(historyControllerProvider.notifier).inputSearchText(text);
        },
      ),
    );
  }
}

class _ViewFilterSortIcon extends ConsumerWidget {
  const _ViewFilterSortIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Icon(Icons.sort),
      ),
      onTap: () {
        ref.read(historyControllerProvider.notifier).changeDateSort();
      },
    );
  }
}

class _ViewBodyHistories extends ConsumerWidget {
  const _ViewBodyHistories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(historyThreadsProvider);
    final selectedThreadId = ref.watch(historySelectedThreadIdProvider);

    if (threads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppText.normal('該当する履歴はありません。'),
      );
    }

    return Visibility(
      visible: ref.watch(historyHeaderVisibleStateProvider),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 4,
        child: SingleChildScrollView(
          child: Wrap(
            verticalDirection: VerticalDirection.down,
            children: threads
                .map((t) => ViewHistoryCard(
                      thread: t,
                      isSelected: selectedThreadId == t.id,
                      onTap: (int threadId) => ref.read(historyControllerProvider.notifier).onLoadTalks(threadId),
                      onDelete: (int threadId) {
                        ref.read(historyControllerProvider.notifier).deleteThread(threadId);
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _ViewHistoryTalkHeaderArea extends ConsumerWidget {
  const _ViewHistoryTalkHeaderArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThread = ref.watch(historySelectedThreadProvider);
    if (currentThread == null) {
      return const SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 16),
        const _ViewContinueButton(),
        const Spacer(),
        Column(
          children: [
            _ViewThreadCreateDate(currentThread.toDateTimeString()),
            _ViewThreadUsageToken(currentThread.totalUseTokens),
            const SizedBox(height: 4),
            _ViewThreadSystemRole(currentThread),
          ],
        ),
        const Spacer(),
        const _ViewFilterAndrListAreaVisibleButton(),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _ViewContinueButton extends ConsumerWidget {
  const _ViewContinueButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        final thread = ref.read(historySelectedThreadProvider);
        if (thread == null) {
          return;
        }

        final talks = ref.read(historyTalksStateProvider);
        ref.read(homeControllerProvider.notifier).loadHistoryThread(thread, talks);
        ref.read(selectPageIndexProvider.notifier).state = 0;
      },
      child: AppText.normal('この会話を再開'),
    );
  }
}

class _ViewThreadCreateDate extends StatelessWidget {
  const _ViewThreadCreateDate(this.dateStr);

  final String dateStr;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText.normal(
        dateStr,
        textColor: AppTheme.primaryColor,
      ),
    );
  }
}

class _ViewThreadUsageToken extends StatelessWidget {
  const _ViewThreadUsageToken(this.totalUseTokenNum);

  final int totalUseTokenNum;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText.small(
        '(このスレッドの総消費トークン数: ${totalUseTokenNum.toCommaFormat()})',
        textColor: Colors.grey,
      ),
    );
  }
}

class _ViewThreadSystemRole extends StatelessWidget {
  const _ViewThreadSystemRole(this.currentThread);

  final TalkThread currentThread;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: (currentThread.isSettingSystem)
            ? AppText.small(currentThread.system!)
            : AppText.small(
                'この会話のSystemは未設定です。',
                textColor: Colors.grey,
              ),
      ),
    );
  }
}

class _ViewFilterAndrListAreaVisibleButton extends ConsumerWidget {
  const _ViewFilterAndrListAreaVisibleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(historyHeaderVisibleStateProvider);
    return IconButton(
      onPressed: () {
        ref.read(historyControllerProvider.notifier).visiblePageHeaderArea();
      },
      icon: isVisible ? const Icon(Icons.expand_less) : const Icon(Icons.expand_more),
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
              return switch (talks[index].roleType) {
                RoleType.user => UserChatRowWidget(talk: talks[index]),
                RoleType.assistant => AssistantChatRowWidget(talk: talks[index]),
                RoleType.image => ImageChatRowWidget(talk: talks[index]),
              };
            },
            childCount: talks.length,
          ),
        ),
      ],
    );
  }
}
