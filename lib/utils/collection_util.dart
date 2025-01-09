class Diff<T> {
  List<T>? added;
  List<T>? removed;
  List<T>? updated;

  Diff({this.added = const [], this.removed = const [], this.updated = const []});
}

class CollectionUtil {
  static Map<Key, T> toMap<T, Key>(List<T>? list, Key Function(T) func) {
    final Map<Key, T> map = {};
    if (list != null && list.isNotEmpty) {
      for (var item in list) {
        map[func(item)] = item;
      }
    }
    return map;
  }

  static Map<Key, List<T>> groupBy<T, Key>(List<T> list, Key Function(T) func) {
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

  static Diff<T> diff<T, V>(List<T>? oldList, List<T>? newList, V Function(T) compareProperty) {
    if (oldList == null) {
      return Diff(added: newList ?? [], removed: [], updated: []);
    }
    if (newList == null) {
      return Diff(added: [], removed: oldList ?? [], updated: []);
    }
    final oldMap = toMap(oldList, compareProperty);
    final newMap = toMap(newList, compareProperty);
    final added = newMap.values.where((e) => !oldMap.containsKey(compareProperty(e))).toList();
    final removed = oldMap.values.where((e) => !newMap.containsKey(compareProperty(e))).toList();
    final updated = newMap.values.where((e) => oldMap.containsKey(compareProperty(e))).toList();
    return Diff(added: added, removed: removed, updated: updated);
  }

  static bool isNotNull<T>(List<T>? list) {
    return list != null && list.isNotEmpty;
  }
}
