// lib/utils/secure_storage_helper.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  // Singleton instance
  static final SecureStorageHelper _instance = SecureStorageHelper._internal();
  factory SecureStorageHelper() => _instance; // Factory constructor
  SecureStorageHelper._internal(); // Private constructor

  // The actual FlutterSecureStorage instance this helper wraps
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- THIS IS THE CRUCIAL GETTER ---
  // It allows other classes to get the actual FlutterSecureStorage instance
  FlutterSecureStorage get storage => _storage;

  // You can keep your convenience methods here if you use them elsewhere
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}