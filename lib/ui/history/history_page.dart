import 'package:assistant_me/ui/history/history_card.dart';
import 'package:assistant_me/ui/history/history_controller.dart';
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
    } else {
      return const _ViewBodyHistories();
    }
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

    return Padding(
      padding: const EdgeInsets.all(16),
      // 画面を上下に区切る
      child: Column(
        children: [
          Wrap(
            children: threads.map((e) => ViewHistoryCard(thread: e)).toList(),
          ),
        ],
      ),
    );
  }
}
