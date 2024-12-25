Map<Key, T> toMap<T, Key>(List<T> list, Key Function(T) func) {
  final Map<Key, T> map = {};
  if (list.isNotEmpty) {
    for (var item in list) {
      map[func(item)] = item;
    }
  }
  return map;
}

Map<Key, List<T>> groupBy<T, Key>(List<T> list, Key Function(T) func) {
  final Map<Key, List<T>> map = {};
  if (list.isNotEmpty) {
    for (var item in list) {
      Key key = func(item);
      if (!map.containsKey(key)) map[key] = [];
      map[key]!.add(item);
    }
  }
  return map;
}
