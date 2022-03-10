import 'package:flutter/material.dart';

import 'loading.dart';
import 'chart.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "COIN",
      initialRoute: '/loading',
      routes: {
        '/chart': (context) => const ChartScreen(),
        '/loading': (context) => const LoadingScreen()
      },
    );
  }
}

