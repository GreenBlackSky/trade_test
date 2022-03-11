import "dart:convert";

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'storage.dart';

DateTime dateFromTimestamp(double timestamp) {
  return DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).round());
}

int timestampFromDateTime(DateTime dateTime) {
  return dateTime.millisecondsSinceEpoch ~/ 1000;
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
    Uri.parse('ws://localhost:8000/update/${storage.currentTickerName}'),
  );
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(enablePinching: true);
    _trackballBehavior = TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
        tooltipSettings: InteractiveTooltip(format: 'point.x: point.y'),
        hideDelay: 2000);
    super.initState();
  }

  Widget buildChooseTickerButton() {
    return DropdownButton<String>(
      value: storage.currentTickerName,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        storage.currentTickerName = newValue!;
        Navigator.of(context).pushReplacementNamed("/loading_data");
      },
      items: storage.tickerNames.map<DropdownMenuItem<String>>((dynamic value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget buildGraph() {
    List<ChartData> chartData = [];
    for (Map record in storage.data) {
      chartData
          .add(ChartData(dateFromTimestamp(record['time']), record['value']));
    }
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.seconds,
        visibleMinimum: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
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
      zoomPanBehavior: _zoomPanBehavior,
      trackballBehavior: _trackballBehavior,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tickers"),
        ),
        body: Center(
            child: Column(
          children: [
            buildChooseTickerButton(),
            Expanded(
              child: StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    storage.addData(jsonDecode(snapshot.data as String));
                  }
                  return buildGraph();
                },
              ),
            ),
          ],
          mainAxisSize: MainAxisSize.max,
        )));
  }
}
