import 'package:sorted_list/sorted_list.dart';

class DataStorage {
  Map<String, List> _storage = {};

  void addData(Map record) {
    String tickerName = record.remove('name');
    if (!_storage.containsKey(tickerName)) {
      _storage[tickerName] = SortedList((a, b) {
        if (a['time'] > b['time']) {
          return 1;
        } else if (a['time'] < b['time']) {
          return -1;
        }
        return 0;
      });
    }
    _storage[tickerName]!.add(record);
  }

  List<String> getTickerNames() {
    var ret = _storage.keys.toList();
    ret.sort();
    return ret;
  }

  List getData(String tickerName) {
    return _storage[tickerName]!;
  }
}

var storage = DataStorage();
