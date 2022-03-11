import "dart:convert";
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'storage.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int timestampFromDateTime(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  @override
  void initState() {
    super.initState();
    fetchOlderData();
  }

  Future<void> fetchOlderData() async {
    var end = DateTime.now().toUtc();
    var start = end.subtract(const Duration(minutes: 5));
    var uri = Uri.http('localhost:8000', '/history', <String, String>{
      "start": start.toIso8601String(),
      "end": end.toIso8601String()
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
