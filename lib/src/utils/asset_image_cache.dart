import 'dart:async';
import 'package:flutter/material.dart';

class AssetImageInfoCache {
  static final Map<String, ImageInfo> _cache = {};

  static ImageInfo? get(String assetPath) => _cache[assetPath];

  static Future<ImageInfo> load(String assetPath) async {
    final existing = _cache[assetPath];
    if (existing != null) return existing;
    final info = await _resolveImage(assetPath);
    _cache[assetPath] = info;
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
}
