import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';

/// 缓存条目
///
/// 包含数据和过期时间
class CacheEntry<T> {
  final T data;
  final DateTime expireAt;

  CacheEntry(this.data, Duration duration)
      : expireAt = DateTime.now().add(duration);

  /// 检查缓存是否已过期
  bool get isExpired => DateTime.now().isAfter(expireAt);

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'expireAt': expireAt.millisecondsSinceEpoch,
    };
  }
}

/// 缓存管理器
///
/// 提供内存缓存和 SharedPreferences 持久化缓存
/// 支持自动过期和手动清除
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  /// 内存缓存
  final Map<String, CacheEntry<dynamic>> _memoryCache = {};

  /// SharedPreferences 实例（延迟初始化）
  SharedPreferences? _prefs;

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化缓存管理器
  /// 应在应用启动时调用一次
  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// 获取缓存
  ///
  /// [key] - 缓存键
  /// [fromDisk] - 是否同时检查磁盘缓存（默认true）
  /// 返回缓存数据或 null（如果未找到或已过期）
  T? get<T>(String key, {bool fromDisk = true}) {
    if (!AppConfig.enableCache) return null;

    // 1. 检查内存缓存
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return memoryEntry.data as T;
    }

    // 2. 检查磁盘缓存（如果启用）
    if (fromDisk && _prefs != null) {
      final diskData = _prefs!.getString(_getDiskKey(key));
      if (diskData != null) {
        try {
          final json = jsonDecode(diskData) as Map<String, dynamic>;
          final expireAt = DateTime.fromMillisecondsSinceEpoch(
            json['expireAt'] as int,
          );

          if (DateTime.now().isBefore(expireAt)) {
            // 将磁盘缓存加载到内存
            final data = json['data'] as T;
            _memoryCache[key] = CacheEntry(
              data,
              expireAt.difference(DateTime.now()),
            );
            return data;
          } else {
            // 磁盘缓存已过期，删除
            _prefs!.remove(_getDiskKey(key));
          }
        } catch (e) {
          // 解析失败，删除无效缓存
          _prefs!.remove(_getDiskKey(key));
        }
      }
    }

    return null;
  }

  /// 设置缓存
  ///
  /// [key] - 缓存键
  /// [data] - 缓存数据
  /// [duration] - 过期时间（默认使用 AppConfig.cacheExpirationMinutes）
  /// [toDisk] - 是否同时保存到磁盘（默认false，复杂数据类型慎用）
  Future<void> set<T>(
    String key,
    T data, {
    Duration? duration,
    bool toDisk = false,
  }) async {
    if (!AppConfig.enableCache) return;

    final cacheDuration = duration ??
        Duration(minutes: AppConfig.cacheExpirationMinutes);

    // 1. 保存到内存
    _memoryCache[key] = CacheEntry(data, cacheDuration);

    // 2. 保存到磁盘（如果启用且可以序列化）
    if (toDisk && _prefs != null) {
      try {
        final entry = CacheEntry(data, cacheDuration);
        final json = jsonEncode({
          'data': data,
          'expireAt': entry.expireAt.millisecondsSinceEpoch,
        });
        await _prefs!.setString(_getDiskKey(key), json);
      } catch (e) {
        // 无法序列化的数据（如复杂对象）跳过磁盘缓存
      }
    }
  }

  /// 清除指定键的缓存
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    if (_prefs != null) {
      await _prefs!.remove(_getDiskKey(key));
    }
  }

  /// 清除所有缓存
  Future<void> clear() async {
    _memoryCache.clear();
    if (_prefs != null) {
      final keys = _prefs!.getKeys().where((k) => k.startsWith('cache_'));
      for (final key in keys) {
        await _prefs!.remove(key);
      }
    }
  }

  /// 清理过期缓存
  Future<void> clearExpired() async {
    // 清理内存过期缓存
    _memoryCache.removeWhere((key, entry) => entry.isExpired);

    // 清理磁盘过期缓存
    if (_prefs != null) {
      final keys = _prefs!.getKeys().where((k) => k.startsWith('cache_'));
      for (final key in keys) {
        final data = _prefs!.getString(key);
        if (data != null) {
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final expireAt = DateTime.fromMillisecondsSinceEpoch(
              json['expireAt'] as int,
            );
            if (DateTime.now().isAfter(expireAt)) {
              await _prefs!.remove(key);
            }
          } catch (e) {
            await _prefs!.remove(key);
          }
        }
      }
    }
  }

  /// 获取内存缓存数量
  int get memoryCacheCount => _memoryCache.length;

  /// 获取磁盘缓存数量
  int get diskCacheCount {
    if (_prefs == null) return 0;
    return _prefs!.getKeys().where((k) => k.startsWith('cache_')).length;
  }

  /// 获取磁盘缓存键名
  String _getDiskKey(String key) => 'cache_$key';
}
