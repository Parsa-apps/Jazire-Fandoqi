import 'package:flutter/material.dart';

class AssetManager {
  static const String illustrationsPath = 'assets/illustrations/';
  static const String mascotPath = 'assets/mascot/';
  
  // Cache for preloaded images
  static final Map<String, ImageProvider> _cache = {};

  static ImageProvider getImage(String name) {
    if (_cache.containsKey(name)) {
      return _cache[name]!;
    }
    
    final path = name.contains('/') ? name : '$illustrationsPath$name';
    final provider = AssetImage(path);
    _cache[name] = provider;
    return provider;
  }

  static void precache(BuildContext context, List<String> names) {
    for (final name in names) {
      precacheImage(getImage(name), context);
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}

/// A wrapper around Image.asset that uses AssetManager and handles loading/error states.
class FandoghiImage extends StatelessWidget {
  final String name;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FandoghiImage({
    super.key,
    required this.name,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetManager.getImage(name),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}
