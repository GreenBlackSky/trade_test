class DataStorage {
  Map<String, List> _storage = {};

  void addData(Map record) {
    String name = record.remove('name');
    if(!_storage.containsKey(name)) {
      _storage[name] = [];
    }
    _storage[name]!.add(record);
  }

  Iterable<String> getNames() {
    return _storage.keys;
  }

  List getData(String name) {
    return _storage[name]!;
  }
}

var storage = DataStorage();
