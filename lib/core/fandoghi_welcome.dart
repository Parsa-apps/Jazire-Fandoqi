import 'package:flutter/foundation.dart';

/// Tracks whether the welcome bunny animation has already been shown
/// in the current app session (and across sessions, once persisted).
class FandoghiWelcome {
  FandoghiWelcome._();

  /// `true` if the welcome animation is currently playing on screen.
  static final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  /// In-memory flag: have we already shown the welcome this session?
  /// Reset only when the app process is killed.
  static bool _shownThisSession = false;

  /// Public read-only flag so the overlay knows whether to schedule
  /// the welcome again.
  static bool get shownThisSession => _shownThisSession;

  /// Mark the welcome as having been shown. After this, [_shownThisSession]
  /// returns `true` until the process is restarted.
  static void markShown() {
    _shownThisSession = true;
  }

  /// Force the welcome to be shown again on next launch (useful for
  /// the "Replay intro" button in parent settings).
  static void reset() {
    _shownThisSession = false;
  }
}
