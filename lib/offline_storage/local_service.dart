import 'package:agriproduce/constant/appLogger.dart';
import 'package:get_storage/get_storage.dart';

class LocalStorageService<T> {
  final GetStorage _storage = GetStorage();

  // Save a single item to storage
  void saveItem(String key, T item, Map<String, dynamic> Function(T) toJson) {
    List<dynamic> cachedItems = _storage.read<List<dynamic>>(key) ?? [];
    List<T> items = cachedItems.map((json) => json as T).toList();

    if (!items.any((existing) => (existing as dynamic).id == (item as dynamic).id)) {
      items.add(item);
      _storage.write(key, items.map((item) => toJson(item)).toList());
      AppLogger.logInfo('Item saved locally under key $key: ${toJson(item)}');
    }
  }

  // Retrieve all items from storage
  List<T> getAllItems(String key, T Function(Map<String, dynamic>) fromJson) {
    List<dynamic> cachedItems = _storage.read<List<dynamic>>(key) ?? [];
    AppLogger.logInfo('Items retrieved locally under key $key.');
    return cachedItems.map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }

  // Check if data is cached
  bool isDataCached(String key) {
    bool cached = _storage.hasData(key);
    AppLogger.logInfo('Is data cached for key $key: $cached');
    return cached;
  }

  // Delete an item from storage
  void deleteItem(
      String key, String id, T Function(Map<String, dynamic>) fromJson) {
    List<dynamic> cachedItems = _storage.read<List<dynamic>>(key) ?? [];
    List<T> items = cachedItems.map((json) => fromJson(json as Map<String, dynamic>)).toList();

    items.removeWhere((item) => (item as dynamic).id == id);

    _storage.write(key, items.map((item) => (item as dynamic).toJson()).toList());
    AppLogger.logInfo('Item with id $id deleted locally from key $key.');
  }
}
