import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';

class AssetImageInfoCache {
  static final LinkedHashMap<String, _Entry> _cache = LinkedHashMap();
  static int _currentBytes = 0;
  static int _maxBytes = 50 * 1024 * 1024; // ~50MB default budget

  static void configure({int? maxBytes}) {
    if (maxBytes != null && maxBytes > 0) {
      _maxBytes = maxBytes;
      _evictIfNeeded();
    }
  }

  static ImageInfo? get(String assetPath) => _cache[assetPath]?.info;

  static Future<ImageInfo> load(String assetPath) async {
    final existing = _cache.remove(assetPath);
    if (existing != null) {
      // re-insert to mark as recently used
      _cache[assetPath] = existing..touch();
      return existing.info;
    }
    final info = await _resolveImage(assetPath);
    final bytes = _estimateBytes(info);
    _cache[assetPath] = _Entry(info: info, bytes: bytes)..touch();
    _currentBytes += bytes;
    _evictIfNeeded();
    return info;
  }

  static Future<void> precacheAll(BuildContext context, Iterable<String> assetPaths) async {
    for (final path in assetPaths) {
      await precache(context, path);
    }
  }

  static Future<void> precache(BuildContext context, String assetPath) async {
    try {
      await precacheImage(AssetImage(assetPath), context);
    } catch (_) {
      // ignore failures for missing assets
    }
    try {
      await load(assetPath);
    } catch (_) {
      // ignore failures for missing assets
    }
  }

  static Future<ImageInfo> _resolveImage(String assetPath) async {
    final imageProvider = AssetImage(assetPath);
    final completer = Completer<ImageInfo>();
    final stream = imageProvider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }, onError: (error, stackTrace) {
      completer.completeError(error, stackTrace);
    });
    stream.addListener(listener);
    try {
      final info = await completer.future;
      return info;
    } finally {
      stream.removeListener(listener);
    }
  }

  static int _estimateBytes(ImageInfo info) {
    final w = info.image.width;
    final h = info.image.height;
    return w * h * 4; // approximate RGBA bytes
  }

  static void _evictIfNeeded() {
    while (_currentBytes > _maxBytes && _cache.isNotEmpty) {
      final oldestKey = _cache.keys.first;
      final oldest = _cache.remove(oldestKey);
      if (oldest != null) {
        _currentBytes -= oldest.bytes;
      }
    }
  }

  static void clear() {
    _cache.clear();
    _currentBytes = 0;
  }
}

class _Entry {
  final ImageInfo info;
  final int bytes;
  DateTime lastAccess;
  _Entry({required this.info, required this.bytes}) : lastAccess = DateTime.now();
  void touch() => lastAccess = DateTime.now();
}
