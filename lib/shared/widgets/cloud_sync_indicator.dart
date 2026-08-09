import 'package:flutter/material.dart';
import '../../core/cloud_sync_service.dart';

/// ویجت نشان‌دهندهٔ وضعیت سنکرونایز ابری
/// 
/// نمایش می‌دهد:
/// - 🔄 در حال سنکرونایز
/// - ✅ آخرین بار دقیقاً 5 دقیقه پیش
/// - ⚠️ خطا / بدون اینترنت

class CloudSyncIndicator extends StatefulWidget {
  final CloudSyncService service;
  final bool showLabel;
  final bool compact;

  const CloudSyncIndicator({
    Key? key,
    required this.service,
    this.showLabel = true,
    this.compact = false,
  }) : super(key: key);

  @override
  State<CloudSyncIndicator> createState() => _CloudSyncIndicatorState();
}

class _CloudSyncIndicatorState extends State<CloudSyncIndicator> {
  late final Stream<void> _syncStream;

  @override
  void initState() {
    super.initState();
    // تازه‌کردن هر ثانیه برای نمایش "دقیقه پیش"
    _syncStream = Stream.periodic(const Duration(seconds: 1)).map((_) => null);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, child) {
        final isSyncing = widget.service.isSyncing;
        final lastSyncTime = widget.service.lastSyncTime;
        final lastError = widget.service.lastSyncError;

        // حالت 1: درحال سنکرونایز
        if (isSyncing) {
          return _buildSyncingState();
        }

        // حالت 2: خطا / بدون اینترنت
        if (lastError != null) {
          return _buildErrorState(lastError);
        }

        // حالت 3: موفق
        if (lastSyncTime != null) {
          return _buildSuccessState(lastSyncTime);
        }

        // حالت 4: هیچ‌هنوز سنکرونایز نشده
        return _buildPendingState();
      },
    );
  }

  Widget _buildSyncingState() {
    if (widget.compact) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.blue[400]),
            ),
          ),
          if (widget.showLabel) ...[
            const SizedBox(width: 6),
            const Text(
              'سنکرونایز شود می‌کند...',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    if (widget.compact) {
      return Tooltip(
        message: error,
        child: const Text('⚠️', style: TextStyle(fontSize: 18)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 14)),
          if (widget.showLabel) ...[
            const SizedBox(width: 6),
            Tooltip(
              message: error,
              child: const Text(
                'بدون اتصال',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessState(DateTime lastSync) {
    final minutesAgo = DateTime.now().difference(lastSync).inMinutes;
    final timeStr = minutesAgo == 0 ? 'اکنون' : 'قبل از $minutesAgo دقیقه';

    if (widget.compact) {
      return Tooltip(
        message: 'آخرین همگام‌سازی: $timeStr',
        child: const Text('✅', style: TextStyle(fontSize: 18)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✅', style: TextStyle(fontSize: 14)),
          if (widget.showLabel) ...[
            const SizedBox(width: 6),
            Text(
              'سنکرونایز: $timeStr',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingState() {
    if (widget.compact) {
      return const Text('⏳', style: TextStyle(fontSize: 18));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⏳', style: TextStyle(fontSize: 14)),
          if (widget.showLabel) ...[
            const SizedBox(width: 6),
            const Text(
              'منتظر سنکرونایز...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// نسخهٔ Compact - برای App Bar یا header
class CompactCloudSyncIndicator extends StatelessWidget {
  final CloudSyncService service;

  const CompactCloudSyncIndicator({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CloudSyncIndicator(
      service: service,
      showLabel: false,
      compact: true,
    );
  }
}
