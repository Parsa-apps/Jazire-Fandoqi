# Professional ProGuard rules for app size reduction
# Preserves beautiful story audio, billing, and game functionality

-keep class com.parsaapps.amoozesh_fandoghi.MainActivity { *; }
-keep class ir.cafebazaar.poolakey.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn ir.cafebazaar.poolakey.**
-keepclassmembers class * { @android.webkit.JavascriptInterface <methods>; }

# 📷 Image Picker & uCrop (ImageCropper)
-keep class com.yalantis.ucrop.** { *; }
-keep interface com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**
-keep class vn.hunghd.flutter.plugins.imagecropper.** { *; }
-dontwarn vn.hunghd.flutter.plugins.imagecropper.**
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
