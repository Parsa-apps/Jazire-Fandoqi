import 'package:flutter/material.dart';
import 'package:amoozesh_fandoghi/core/cartoons/aparat_service.dart';
import 'package:amoozesh_fandoghi/shared/widgets/professional_skeleton.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🖼️ CARTOON COVER IMAGE — نمایش «عکس واقعی» شخصیت‌های کارتون
///
/// کودک با دیدن قاب واقعی کارتون (از سرورهای آپارات) بلافاصله
/// می‌فهمد هر کارتون کدام است (مثلاً باب اسفنجی یا کوکوملون).
/// اگر اینترنت در دسترس نبود یا پوستر بارگیری نشد، همان آیکون
/// (ایموجی) قبلی روی گرادیان به‌عنوان جایگزین نمایش داده می‌شود.
/// ═══════════════════════════════════════════════════════════════
class CartoonCoverImage extends StatefulWidget {
  final String? videoHash;
  final String? searchQuery;
  final String? coverAsset;
  final String fallbackEmoji;
  final Gradient fallbackGradient;
  final double emojiSize;
  final BoxFit fit;
  final int? cacheWidth;

  /// اگر true باشد، یک نشان کوچک ایموجی گوشهٔ عکس هم باقی می‌ماند تا
  /// هویت بصری کارتون حتی حین بارگیری عکس مشخص باشد.
  final bool showEmojiBadge;

  const CartoonCoverImage({
    super.key,
    this.videoHash,
    this.searchQuery,
    this.coverAsset,
    required this.fallbackEmoji,
    required this.fallbackGradient,
    this.emojiSize = 48,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.showEmojiBadge = false,
  });

  @override
  State<CartoonCoverImage> createState() => _CartoonCoverImageState();
}

class _CartoonCoverImageState extends State<CartoonCoverImage> {
  String? _url;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // اگر قبلاً کش شده (مثلاً ورود دوباره به صفحه)، فوری و بدون چشمک نمایش بده.
    _url = AparatService.cachedThumbnail(
      videoHash: widget.videoHash,
      searchQuery: widget.searchQuery,
    );
    if (_url == null && _hasSource) _load();
  }

  @override
  void didUpdateWidget(covariant CartoonCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // وقتی کارتون عوض می‌شود (مثلاً اسلایدر «ویژه امروز» یا تغییر قسمت)،
    // باید پوستر جدید بارگیری شود — State در جای خود باقی می‌ماند.
    if (oldWidget.videoHash != widget.videoHash ||
        oldWidget.searchQuery != widget.searchQuery) {
      // مقدار را مستقیم عوض می‌کنیم؛ build بلافاصله بعد از این callback اجرا می‌شود.
      _url = AparatService.cachedThumbnail(
        videoHash: widget.videoHash,
        searchQuery: widget.searchQuery,
      );
      if (_url == null && _hasSource) _load();
    }
  }

  bool get _hasSource =>
      (widget.videoHash != null && widget.videoHash!.isNotEmpty) ||
      (widget.searchQuery != null && widget.searchQuery!.trim().isNotEmpty);

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final url = await AparatService.thumbnailFor(
        videoHash: widget.videoHash,
        searchQuery: widget.searchQuery,
      );
      if (!mounted) return;
      setState(() {
        _url = url;
        _loading = false;
      });
    } catch (_) {
      // در حالت آفلاین/خطا همان پوستر ایموجی باقی می‌ماند.
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(gradient: widget.fallbackGradient),
      child: Center(
        child: Text(
          widget.fallbackEmoji,
          style: TextStyle(fontSize: widget.emojiSize),
        ),
      ),
    );
  }

  Widget _buildEmojiBadgeWidget() {
    if (!widget.showEmojiBadge) return const SizedBox.shrink();
    return Positioned(
      left: 6,
      bottom: 6,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
          ),
          child: Text(
            widget.fallbackEmoji,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fallback = _buildFallback();

    // 1️⃣ اگر پوستر آفلاین (asset) تعریف شده باشد، با اولویت و بدون نیاز به شبکه نمایش می‌دهیم.
    if (widget.coverAsset != null && widget.coverAsset!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.coverAsset!,
            fit: widget.fit,
            cacheWidth: widget.cacheWidth,
            errorBuilder: (context, error, stackTrace) => fallback,
          ),
          _buildEmojiBadgeWidget(),
        ],
      );
    }

    final url = _url;

    if (url == null) {
      if (_loading) {
        return Center(
          child: ProfessionalSkeleton(
            isLoading: true,
            child: fallback,
            itemCount: 1,
            type: SkeletonType.card,
          ),
        );
      }
      return fallback;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: widget.fit,
          cacheWidth: widget.cacheWidth,
          // تا قبل از آماده‌شدن کامل عکس، همان ایموجی نشان داده شود.
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame == null) return fallback;
            return child;
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return fallback;
          },
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
        _buildEmojiBadgeWidget(),
      ],
    );
  }
}
