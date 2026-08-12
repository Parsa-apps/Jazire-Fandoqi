import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 🛡️ Window-level privacy protection (Android FLAG_SECURE).
///
/// While a parent-facing screen (PIN entry, paywall, backup) is open, the
/// window is marked FLAG_SECURE: screenshots and screen recordings capture a
/// blank area and the app is hidden from the recents preview.
class PrivacyProtection {
  PrivacyProtection._();

  static const MethodChannel _channel = MethodChannel('kudake_iran/privacy');

  static Future<void> enableSecureWindow(bool secure) async {
    try {
      await _channel.invokeMethod<void>(
        'setSecureWindow',
        <String, Object?>{'secure': secure},
      );
    } catch (_) {
      // Non-Android platforms / missing plugin: nothing to do.
    }
  }
}

/// Wraps a subtree and marks the window secure while it is mounted.
///
/// Used around the parent panel, the paywall and the backup dialogs so a
/// child (or a malicious app) cannot capture the parent PIN or payment flow.
class SecureWindowScope extends StatefulWidget {
  const SecureWindowScope({super.key, required this.child});

  final Widget child;

  @override
  State<SecureWindowScope> createState() => _SecureWindowScopeState();
}

class _SecureWindowScopeState extends State<SecureWindowScope> {
  @override
  void initState() {
    super.initState();
    PrivacyProtection.enableSecureWindow(true);
  }

  @override
  void dispose() {
    PrivacyProtection.enableSecureWindow(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
