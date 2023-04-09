import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:assistant_me/ui/graph/graph_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphPage extends ConsumerWidget {
  const GraphPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('月ごとの利用量'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: const [
            _ViewDate(),
            Divider(),
            _ViewTotalUsage(),
            Flexible(child: _ViewMonthGraph()),
          ],
        ),
      ),
    );
  }
}

class _ViewDate extends ConsumerWidget {
  const _ViewDate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateStateProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Text('${selectedDate.year}年 ${selectedDate.month}月', style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => _showMonthPicker(context, ref, selectedDate),
          icon: LineIcon(LineIcons.calendar),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => ref.read(graphControllerProvider.notifier).refresh(),
          icon: LineIcon(LineIcons.syncIcon),
          tooltip: 'グラフを更新する',
        ),
      ],
    );
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    showMonthPicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
      initialDate: selectedDate,
    ).then((DateTime? selectDate) => ref.read(graphControllerProvider.notifier).setSelectedDate(selectDate));
  }
}

class _ViewTotalUsage extends ConsumerWidget {
  const _ViewTotalUsage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = ref.watch(amountByMonthProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text('当月の利用料', style: TextStyle(fontSize: 20)),
            Text('約 $amount 円', style: const TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(width: 16),
        const _ViewYenPerDollarField(),
      ],
    );
  }
}

class _ViewYenPerDollarField extends ConsumerWidget {
  const _ViewYenPerDollarField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentYen = ref.watch(yenPerDollar);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 60,
          child: TextFormField(
            decoration: const InputDecoration(
              label: Text('1ドル'),
              counterText: '',
            ),
            maxLength: 3,
            textAlign: TextAlign.center,
            initialValue: currentYen.toString(),
            onChanged: (String? value) {
              if (value != null) {
                ref.read(graphControllerProvider.notifier).setYenPerDollar(value);
              }
            },
          ),
        ),
        const Text('円'),
      ],
    );
  }
}

class _ViewMonthGraph extends ConsumerWidget {
  const _ViewMonthGraph();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(threadsByMonthFutureProvider).when(
          data: (data) {
            if (data.isEmpty) {
              return const Center(
                child: Text('この月のデータはありません。'),
              );
            }
            return _ViewGraph(data);
          },
          error: (e, s) {
            return Center(
              child: Text('エラーが発生しました。詳細を確認してください\n $e \n $s', style: const TextStyle(color: Colors.red)),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}

class _ViewGraph extends ConsumerWidget {
  const _ViewGraph(this.threads);

  final List<TalkThread> threads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yen = ref.watch(yenPerDollar);

    return SfCartesianChart(
      primaryXAxis: NumericAxis(labelFormat: '{value}日', interval: 1),
      primaryYAxis: NumericAxis(numberFormat: NumberFormat('###,###円')),
      tooltipBehavior: TooltipBehavior(enable: true, header: '詳細'),
      series: <ChartSeries>[
        StackedColumnSeries<_ChartData, int>(
          color: AppTheme.gpt3Color,
          dataLabelMapper: (datum, index) => 'gpt3',
          dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(color: Colors.white, fontSize: 18)),
          dataSource: _createChartData(targetModel: LlmModel.gpt3, yen: yen),
          xValueMapper: (_ChartData data, _) => data.day,
          yValueMapper: (_ChartData data, _) => data.totalAmount,
        ),
        StackedColumnSeries<_ChartData, int>(
          color: AppTheme.gpt4Color,
          dataLabelMapper: (datum, index) => 'gpt4',
          dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(color: Colors.white, fontSize: 18)),
          dataSource: _createChartData(targetModel: LlmModel.gpt4, yen: yen),
          xValueMapper: (_ChartData data, _) => data.day,
          yValueMapper: (_ChartData data, _) => data.totalAmount,
        ),
      ],
    );
  }

  List<_ChartData> _createChartData({required LlmModel targetModel, required int yen}) {
    // 同日をまとめながらチャートデータを作成する
    final resultMap = <int, _ChartData>{};
    final targetThread = threads.where((e) => e.model == targetModel);

    for (var thread in targetThread) {
      final key = thread.createAt.day;
      if (resultMap.containsKey(key)) {
        resultMap.update(key, (value) => value.copyWithAddAmount(thread.calcAmount(yen: yen)));
      } else {
        resultMap[key] = _ChartData(key, thread.calcAmount(yen: yen));
      }
    }
    final t = resultMap.values.toList();
    t.sort((a, b) => a.day.compareTo(b.day));
    return t;
  }
}

class _ChartData {
  _ChartData(this.day, this.totalAmount);
  final int day;
  final int totalAmount;

  _ChartData copyWithAddAmount(int amount) {
    return _ChartData(day, totalAmount + amount);
  }
}
