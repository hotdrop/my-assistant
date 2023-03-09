import 'package:assistant_me/model/app_settings.dart';
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
        Text('${selectedDate.year}年 ${selectedDate.month}月', style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showMonthPicker(context, ref, selectedDate),
          icon: LineIcon(LineIcons.calendar, color: Colors.blue),
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
    final tokenNum = ref.watch(totalTokenByMonthProvider);
    final amount = ref.watch(amountByMonthStateProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text('当月の総利用トークン数', style: TextStyle(fontSize: 20)),
            Text('$tokenNum (約 $amount 円)', style: const TextStyle(fontSize: 24)),
            Text(
              '(${appSettings.amountDollerPerTokenNum}トークンあたり＄${appSettings.amountDollerPerTokenNum}で計算してます。)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
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

class _ViewGraph extends StatelessWidget {
  const _ViewGraph(this.threads);

  final List<TalkThread> threads;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        labelFormat: '{value}日',
        interval: 1,
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat('###,###'),
      ),
      tooltipBehavior: TooltipBehavior(enable: true, header: '詳細'),
      series: <ChartSeries>[
        LineSeries<_ChartData, int>(
          dataSource: _dataToChartData(),
          xValueMapper: (_ChartData data, _) => data.day,
          yValueMapper: (_ChartData data, _) => data.tokenNum,
        ),
      ],
    );
  }

  List<_ChartData> _dataToChartData() {
    // 同日をまとめながらチャートデータを作成する
    final resultMap = <int, _ChartData>{};
    for (var thread in threads) {
      final key = thread.createAt.day;
      if (resultMap.containsKey(key)) {
        resultMap.update(key, (value) => value.copyWithAddToken(thread.totalTalkTokenNum));
      } else {
        resultMap[key] = _ChartData(key, thread.totalTalkTokenNum);
      }
    }
    final results = resultMap.values.toList();
    results.sort((a, b) => a.day.compareTo(b.day));
    return results;
  }
}

class _ChartData {
  _ChartData(this.day, this.tokenNum);
  final int day;
  final int tokenNum;

  _ChartData copyWithAddToken(int tn) {
    return _ChartData(day, tokenNum + tn);
  }
}