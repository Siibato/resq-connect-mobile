import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

abstract class SecureStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> deleteAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> deleteRefreshToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();
  Future<void> clearAll();
}

class SecureStorageImpl implements SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorageImpl(this._storage);

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: StorageKeys.accessToken, value: token);
    } catch (e) {
      throw CacheException('Failed to save access token: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: StorageKeys.accessToken);
    } catch (e) {
      throw CacheException('Failed to get access token: $e');
    }
  }

  @override
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: StorageKeys.accessToken);
    } catch (e) {
      throw CacheException('Failed to delete access token: $e');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: StorageKeys.refreshToken, value: token);
    } catch (e) {
      throw CacheException('Failed to save refresh token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: StorageKeys.refreshToken);
    } catch (e) {
      throw CacheException('Failed to get refresh token: $e');
    }
  }

  @override
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: StorageKeys.refreshToken);
    } catch (e) {
      throw CacheException('Failed to delete refresh token: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: StorageKeys.userCache, value: userJson);
    } catch (e) {
      throw CacheException('Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = await _storage.read(key: StorageKeys.userCache);
      if (userJson == null) return null;
      
      final Map<String, dynamic> json = jsonDecode(userJson);
      return UserModel.fromJson(json);
    } catch (e) {
      throw CacheException('Failed to get user: $e');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _storage.delete(key: StorageKeys.userCache);
    } catch (e) {
      throw CacheException('Failed to delete user: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException('Failed to clear storage: $e');
    }
  }
}

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorageImpl(ref.watch(flutterSecureStorageProvider));
});