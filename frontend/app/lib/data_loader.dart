import "dart:convert";
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'storage.dart';

class DataLoader extends StatefulWidget {
  const DataLoader({Key? key}) : super(key: key);

  @override
  State<DataLoader> createState() => _DataLoaderState();
}

class _DataLoaderState extends State<DataLoader> {
  int timestampFromDateTime(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  @override
  void initState() {
    super.initState();
    storage.clear();
    fetchOlderData();
  }

  Future<void> fetchOlderData() async {
    DateTime periodEnd = DateTime.now().toUtc();
    DateTime periodStart = periodEnd.subtract(const Duration(minutes: 5));
    var uri = Uri.http('localhost:8000', '/history', <String, String>{
      "start": periodStart.toIso8601String(),
      "end": periodEnd.toIso8601String(),
      "ticker_name": storage.currentTickerName
    });
    http.Response response =
        await http.get(uri, headers: {"Access-Control-Allow-Origin": "*"});
    var responseData = jsonDecode(jsonDecode(response.body));
    for(Map record in responseData) {
      storage.addData(record);
    }
    Navigator.of(context).pushReplacementNamed("/chart");
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("WAIT")),
    );
  }
}
