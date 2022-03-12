import "dart:convert";

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
    Uri.parse('ws://localhost:8000/update/${storage.currentTickerName}'),
  );
  late List<ChartData> chartData;
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;
  late SelectionBehavior _selectionBehavior;
  bool isZoomed = false;

  @override
  void initState() {
    chartData = <ChartData>[];
    for (Map record in storage.data) {
      chartData
          .add(ChartData(dateFromTimestamp(record['time']), record['value']));
    }
    _zoomPanBehavior = ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableMouseWheelZooming: true);
    _trackballBehavior = TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
        tooltipSettings: InteractiveTooltip(format: 'point.x: point.y'),
        hideDelay: 2000);
    _selectionBehavior = SelectionBehavior(enable: true);
    channel.stream.listen((event) {
      setState(() {
        var data = jsonDecode(event as String);
        if (data['name'] == storage.currentTickerName) {
          storage.addData(data);
          chartData
              .add(ChartData(dateFromTimestamp(data['time']), data['value']));
        }
      });
    });
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
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.seconds,
        visibleMaximum: isZoomed ? null : DateTime.now().toUtc(),
        visibleMinimum: isZoomed
            ? null
            : DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
      ),
      series: <ChartSeries<ChartData, DateTime>>[
        LineSeries<ChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (ChartData val, _) => val.x,
            yValueMapper: (ChartData val, _) => val.y,
            selectionBehavior: _selectionBehavior,
            width: 5)
      ],
      zoomPanBehavior: _zoomPanBehavior,
      trackballBehavior: _trackballBehavior,
      onZooming: (ZoomPanArgs args) {
        isZoomed = (args.currentZoomFactor != 1);
      },
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
            Expanded(child: buildGraph()),
          ],
          mainAxisSize: MainAxisSize.max,
        )));
  }
}
