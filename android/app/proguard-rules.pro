# Professional ProGuard rules for app size reduction
# Preserves beautiful story audio, billing, and game functionality

-keep class com.parsaapps.amoozesh_fandoghi.MainActivity { *; }
-keep class ir.cafebazaar.poolakey.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn ir.cafebazaar.poolakey.**
-keepclassmembers class * { @android.webkit.JavascriptInterface <methods>; }
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
