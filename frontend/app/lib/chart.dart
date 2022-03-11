import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'storage.dart';

DateTime dateFromTimestamp(double timestamp) {
  return DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).round());
}

class ChartData {
  ChartData(this.x, this.y);

  final DateTime x;
  final int y;
}

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8000/update/'),
  );

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text("Tickers"),
  //     ),
  //     body: Center(
  //         child: StreamBuilder(
  //       stream: channel.stream,
  //       builder: (context, snapshot) {
  //         return Text(snapshot.hasData ? '${snapshot.data}' : '');
  //       },
  //     )),
  //   );

  @override
  Widget build(BuildContext context) {
    List<ChartData> chartData = [];
    for(Map record in storage.getData('ticker_01')){
      chartData
          .add(ChartData(dateFromTimestamp(record['time']), record['value']));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Tickers"),
        ),
        body: Center(
            child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.seconds,
            ),
          series: <ChartSeries<ChartData, DateTime>>[
            LineSeries<ChartData, DateTime>(
                dataSource: chartData,
                xValueMapper: (ChartData val, _) => val.x,
                yValueMapper: (ChartData val, _) => val.y,
                selectionBehavior: SelectionBehavior(
                    enable: true,
                    selectedColor: Colors.red,
                    selectedBorderWidth: 5,
                    unselectedBorderWidth: 5),
                width: 5)
          ],
          trackballBehavior: TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
              tooltipSettings: InteractiveTooltip(format: 'point.x: point.y'),
              hideDelay: 2000),
          onSelectionChanged: (selectionArgs) {
            int index = selectionArgs.pointIndex;
          },
        )));
  }
}
