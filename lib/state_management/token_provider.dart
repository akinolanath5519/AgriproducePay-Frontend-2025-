import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Secure storage instance
final storage = FlutterSecureStorage();

// Token Provider: This will store the JWT token in memory.
final tokenProvider = StateProvider<String?>((ref) => null);

// Save token in secure storage and update the Riverpod provider.
Future<void> saveToken(String token, WidgetRef ref) async {
  await storage.write(key: 'jwt', value: token);
  ref.read(tokenProvider.notifier).state = token;
}

// Load token from secure storage when the app starts.
Future<void> loadToken(WidgetRef ref) async {
  final token = await storage.read(key: 'jwt');
  ref.read(tokenProvider.notifier).state = token;
}

// Clear token on logout.
Future<void> clearToken(WidgetRef ref) async {
  await storage.delete(key: 'jwt');
  ref.read(tokenProvider.notifier).state = null;
}
