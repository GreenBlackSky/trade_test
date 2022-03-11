import "dart:convert";
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'storage.dart';

class TickerNamesLoader extends StatefulWidget {
  const TickerNamesLoader({Key? key}) : super(key: key);

  @override
  State<TickerNamesLoader> createState() => _TickerNamesLoaderState();
}

class _TickerNamesLoaderState extends State<TickerNamesLoader> {
  int timestampFromDateTime(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  @override
  void initState() {
    super.initState();
    fetchTickerNames();
  }

  Future<void> fetchTickerNames() async {
    var uri = Uri.http('localhost:8000', '/ticker_names');
    http.Response response =
        await http.get(uri, headers: {"Access-Control-Allow-Origin": "*"});
    var responseData = jsonDecode(response.body);
    storage.initStorage(responseData);
    Navigator.of(context).pushReplacementNamed("/loading_data");
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("WAIT")),
    );
  }
}
