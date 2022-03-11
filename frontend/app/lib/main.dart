import 'package:flutter/material.dart';

import 'data_loader.dart';
import 'ticker_names_loader.dart';
import 'chart.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tickers",
      initialRoute: '/loading_ticker_names',
      routes: {
        '/chart': (context) => const ChartScreen(),
        '/loading_data': (context) => const DataLoader(),
        '/loading_ticker_names': (context) => const TickerNamesLoader()
      },
    );
  }
}

