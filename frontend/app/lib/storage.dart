import 'package:sorted_list/sorted_list.dart';

int compareRecords(a, b) {
  if (a['time'] > b['time']) {
    return 1;
  } else if (a['time'] < b['time']) {
    return -1;
  }
  return 0;
}

class DataStorage {
  List data = SortedList(compareRecords);
  List tickerNames = [];
  String currentTickerName = "";

  void initStorage(List tickerNames) {
    tickerNames.sort();
    this.tickerNames = tickerNames;
    currentTickerName = this.tickerNames[0];
  }

  void addData(Map record) {
    data.add(record);
  }

  void clear(){
    data.clear();
  }
}

var storage = DataStorage();
