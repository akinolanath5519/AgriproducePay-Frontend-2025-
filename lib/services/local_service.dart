import 'package:agriproduce/constant/appLogger.dart';

/// Generic Local Service for caching
class LocalService<T> {
  final String label;

  LocalService(this.label);

  void saveItem(T item, Map<String, dynamic> Function(T) toJson) =>
      AppLogger.logInfo('💾 [$label] Saved locally: ${toJson(item)}');

  List<T> getAllItems() {
    AppLogger.logInfo('📦 [$label] Returning cached items (currently empty)');
    return [];
  }

  bool isDataCached() => false;

  void deleteItem(String id) =>
      AppLogger.logInfo('🗑 [$label] Deleted locally: $id');
}
