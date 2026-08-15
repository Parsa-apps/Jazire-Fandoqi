# Professional ProGuard rules for app size reduction
# Preserves beautiful story audio, billing, and game functionality

-keep class com.parsaapps.amoozesh_fandoghi.MainActivity { *; }
-keep class com.parsaapps.amoozesh_fandoghi.SecureStore { *; }
-keep class com.parsaapps.amoozesh_fandoghi.SecurityModule { *; }
-keep class com.parsaapps.amoozesh_fandoghi.BuildConfig { *; }
-keep class com.parsaapps.amoozesh_fandoghi.BazaarBilling { *; }
-keep class com.parsaapps.amoozesh_fandoghi.BillingOutcome { *; }
-keep class com.parsaapps.amoozesh_fandoghi.StoreVendor { *; }
# Store billing SDK uses AIDL/reflection over its own model classes,
# so it must survive shrinking.
-keep class ir.cafebazaar.poolakey.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn ir.cafebazaar.poolakey.**
-keepclassmembers class * { @android.webkit.JavascriptInterface <methods>; }

-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
