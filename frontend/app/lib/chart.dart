import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8000/update/'),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tickers"),
      ),
      body: Center(
          child: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          return Text(snapshot.hasData ? '${snapshot.data}' : '');
        },
      )),
    );
  }
}
